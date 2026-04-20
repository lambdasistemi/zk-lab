{- |
Module      : ZK.DSL.SetMembershipSpec
Description : Hspec suite for ZK.DSL.SetMembership.
Copyright   : (c) lambdasistemi, 2026
License     : Apache-2.0

Pairs unit-test coverage of the specific edge cases named in
@specs/001-set-membership/tasks.md@ (T012, T013) with the
randomized QuickCheck properties from
"ZK.DSL.Properties.SetMembership" (T014, T015).

The suite is the first gate on property parity: every time a new
DSL-level property is added to the Lean module, its QuickCheck
counterpart lands here alongside.
-}
module ZK.DSL.SetMembershipSpec
    ( spec
    ) where

import Test.Hspec (Spec, describe, it, shouldBe)
import Test.Hspec.QuickCheck (prop)

import ZK.DSL.Properties.SetMembership
    ( prop_canonicalization_idempotent
    , prop_empty_rejected
    )
import ZK.DSL.SetMembership
    ( Element (..)
    , fromList
    )

spec :: Spec
spec = do
    describe "fromList" $ do
        it "rejects the empty input (T012 / P5)" $
            fromList ([] :: [Element]) `shouldBe` Nothing

        it "is permutation- and duplicate-invariant (T013 / P4)" $ do
            let x = Element "x"
                y = Element "y"
            fromList [x, x, y] `shouldBe` fromList [y, x]

    describe "properties" $ do
        prop
            "canonicalization is idempotent (T014 / P4)"
            prop_canonicalization_idempotent
        prop
            "empty input is rejected (T015 / P5)"
            prop_empty_rejected
