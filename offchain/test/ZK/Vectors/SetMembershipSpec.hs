{- |
Module      : ZK.Vectors.SetMembershipSpec
Description : Hspec suite for the shared set-membership vector store.
Copyright   : (c) lambdasistemi, 2026
License     : Apache-2.0

Covers tasks T023 (positive cases decode), T024 (tampering cases
decode and reference a valid base case), and T025 (canonicalization
check: every positive case's @canonicalSet@ and @canonicalTag@ agree
with what "ZK.Canonicalize" computes from the raw @set@ input).

The vector store root is resolved in this order:

1. @ZK_LAB_VECTORS@ environment variable, if set.
2. @vectors\/set-membership@ (repo root; nix sandbox with bundled
   vectors).
3. @..\/vectors\/set-membership@ (local @cabal test@ run from the
   @offchain@ subdir).

The whole spec is wrapped in a @beforeAll_@ that fails loudly if
none of those paths resolve, so an accidental skip is impossible.
-}
module ZK.Vectors.SetMembershipSpec
    ( spec
    ) where

import Data.Maybe (maybeToList)
import Data.Text (Text)
import System.Directory (doesDirectoryExist)
import System.Environment (lookupEnv)
import Test.Hspec (Spec, describe, it, runIO, shouldBe, shouldSatisfy)

import ZK.Canonicalize (canonicalTag)
import ZK.DSL.SetMembership.Types (fromList, toList)
import ZK.Vectors.SetMembership
    ( PositiveCase (..)
    , TamperingCase (..)
    , loadAll
    )

spec :: Spec
spec = do
    root <- runIO resolveRoot
    (positives, tamperings) <- runIO (loadAll root)

    describe "positive vectors (T023)" $ do
        it "the store is non-empty" $
            length positives `shouldSatisfy` (> 0)
        it "every case decodes with a non-empty name" $
            map pcName positives `shouldSatisfy` (not . any nullText)

    describe "tampering vectors (T024)" $ do
        it "every tampering references an existing positive case" $ do
            let positiveNames = map pcName positives
            mapM_
                ( \tc ->
                    tcBaseCase tc `shouldSatisfy` (`elem` positiveNames)
                )
                tamperings

    describe "canonicalization check (T025)" $ do
        mapM_ (canonicalizationProp root) positives
  where
    canonicalizationProp root pc = do
        let name = show (pcName pc)
        it (name <> ": fromList(set) has declared canonicalSet/canonicalTag") $ do
            case fromList (pcSet pc) of
                Nothing ->
                    fail
                        ( "positive case "
                            <> name
                            <> " in "
                            <> root
                            <> " has an empty set"
                        )
                Just s -> do
                    toList s `shouldBe` pcCanonicalSet pc
                    canonicalTag s `shouldBe` pcCanonicalTag pc

resolveRoot :: IO FilePath
resolveRoot = do
    envRoot <- lookupEnv "ZK_LAB_VECTORS"
    let candidates =
            maybeToList envRoot
                ++ [ "vectors/set-membership"
                   , "../vectors/set-membership"
                   ]
    pick candidates
  where
    pick [] =
        error
            ( "zk-lab vectors store not found; set ZK_LAB_VECTORS or "
                <> "run from a directory containing "
                <> "vectors/set-membership or ../vectors/set-membership"
            )
    pick (p : ps) = do
        e <- doesDirectoryExist p
        if e then pure p else pick ps

nullText :: Text -> Bool
nullText t = t == mempty
