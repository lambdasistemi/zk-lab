{- |
Module      : ZK.Vectors.SetMembership
Description : Loader + JSON decoders for the shared set-membership vector store.
Copyright   : (c) lambdasistemi, 2026
License     : Apache-2.0

Reads @vectors\/set-membership\/@ (schema in @contracts\/vectors.md@)
into typed Haskell values. Every backend's test suite consumes this
store — no backend-local fixtures (FR-005, constitutional principle
6a).

The loader does not validate against @schema.json@; that gate lives
in the @vectors@ nix check (see @just check-vectors@). The loader
assumes the store has already passed schema validation and fails
loudly if JSON parsing fails.
-}
module ZK.Vectors.SetMembership
    ( PositiveCase (..)
    , TamperingCase (..)
    , Mutation (..)
    , loadAll
    , loadPositiveCases
    , loadTamperingCases
    ) where

import Data.Aeson
    ( FromJSON (..)
    , withObject
    , (.:)
    )
import Data.Aeson qualified as Aeson
import Data.Aeson.Types (Parser)
import Data.ByteString (ByteString)
import Data.ByteString.Base16 qualified as B16
import Data.ByteString.Lazy qualified as BSL
import Data.List (isSuffixOf, sort)
import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.Encoding qualified as TE
import System.Directory (listDirectory)
import System.FilePath ((</>))

import ZK.DSL.SetMembership.Types (Element (..), Value (..))

{- | One valid (set, value ∈ set) fixture. Does not embed a proof —
proofs are backend-specific and regenerated per-backend at test time.
-}
data PositiveCase = PositiveCase
    { pcName :: Text
    , pcSet :: [Element]
    , pcCanonicalSet :: [Element]
    , pcCanonicalTag :: ByteString
    , pcValue :: Value
    , pcCitation :: Text
    }
    deriving stock (Eq, Show)

{- | A deliberate perturbation of a 'PositiveCase' with an expected
@reject@ verdict. References the base case by name so that backends
can re-derive the commitment and proof before applying the mutation.
-}
data TamperingCase = TamperingCase
    { tcName :: Text
    , tcBaseCase :: Text
    , tcMutation :: Mutation
    , tcCitation :: Text
    }
    deriving stock (Eq, Show)

{- | The class of tampering applied. Each constructor's payload is the
extra data carried in the JSON vector beyond the @tag@ discriminator.
-}
data Mutation
    = NonMember Value
    | WrongCommitment [Element]
    | FlippedProofBit Int
    | ReplayAcrossSets [Element]
    deriving stock (Eq, Show)

instance FromJSON PositiveCase where
    parseJSON = withObject "PositiveCase" $ \o -> do
        expectKind o "positive"
        expectVerdict o "accept"
        PositiveCase
            <$> o .: "name"
            <*> (traverse parseHexElement =<< o .: "set")
            <*> (traverse parseHexElement =<< o .: "canonicalSet")
            <*> (parseHex =<< o .: "canonicalTag")
            <*> fmap Value (parseHexElement =<< o .: "value")
            <*> o .: "citation"

instance FromJSON TamperingCase where
    parseJSON = withObject "TamperingCase" $ \o -> do
        expectKind o "tampering"
        expectVerdict o "reject"
        TamperingCase
            <$> o .: "name"
            <*> o .: "baseCase"
            <*> o .: "mutation"
            <*> o .: "citation"

instance FromJSON Mutation where
    parseJSON = withObject "Mutation" $ \o -> do
        tag <- o .: "tag" :: Parser Text
        case tag of
            "non-member" ->
                NonMember . Value <$> (parseHexElement =<< o .: "value")
            "wrong-commitment" ->
                WrongCommitment <$> (traverse parseHexElement =<< o .: "otherSet")
            "flipped-proof-bit" ->
                FlippedProofBit <$> o .: "bitIndex"
            "replay-across-sets" ->
                ReplayAcrossSets <$> (traverse parseHexElement =<< o .: "otherSet")
            other ->
                fail ("unknown mutation tag: " <> T.unpack other)

expectKind :: Aeson.Object -> Text -> Parser ()
expectKind o expected = do
    actual <- o .: "kind"
    if actual == expected
        then pure ()
        else
            fail
                ( "kind must be "
                    <> T.unpack expected
                    <> ", got "
                    <> T.unpack actual
                )

expectVerdict :: Aeson.Object -> Text -> Parser ()
expectVerdict o expected = do
    actual <- o .: "expectedVerdict"
    if actual == expected
        then pure ()
        else
            fail
                ( "expectedVerdict must be "
                    <> T.unpack expected
                    <> ", got "
                    <> T.unpack actual
                )

parseHex :: Text -> Parser ByteString
parseHex t = case B16.decode (TE.encodeUtf8 t) of
    Right b -> pure b
    Left err -> fail ("invalid hex: " <> err)

parseHexElement :: Text -> Parser Element
parseHexElement = fmap Element . parseHex

{- | Load every positive case from @\<root\>\/positive\/\*.json@, in
lexicographic filename order.
-}
loadPositiveCases :: FilePath -> IO [PositiveCase]
loadPositiveCases root = loadJsonDir (root </> "positive")

{- | Load every tampering case from @\<root\>\/tampering\/\*.json@, in
lexicographic filename order.
-}
loadTamperingCases :: FilePath -> IO [TamperingCase]
loadTamperingCases root = loadJsonDir (root </> "tampering")

{- | Load both case lists in one call. @root@ is the directory
containing @positive\/@ and @tampering\/@.
-}
loadAll :: FilePath -> IO ([PositiveCase], [TamperingCase])
loadAll root = do
    ps <- loadPositiveCases root
    ts <- loadTamperingCases root
    pure (ps, ts)

loadJsonDir :: (FromJSON a) => FilePath -> IO [a]
loadJsonDir dir = do
    entries <- listDirectory dir
    let files = sort [dir </> e | e <- entries, ".json" `isSuffixOf` e]
    traverse decodeFile files

decodeFile :: (FromJSON a) => FilePath -> IO a
decodeFile path = do
    bs <- BSL.readFile path
    case Aeson.eitherDecode bs of
        Right x -> pure x
        Left err -> fail (path <> ": " <> err)
