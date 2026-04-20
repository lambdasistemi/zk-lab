{- |
Module      : ZK.DSL.Properties.SetMembership
Description : QuickCheck counterparts of the Lean set-membership properties.
Copyright   : (c) lambdasistemi, 2026
License     : Apache-2.0

Executable, randomized mirror of @lean/ZKLab/SetMembership.lean@.
Property names correspond 1:1 to the Lean identifiers documented in
@specs/001-set-membership/contracts/properties.md@. Success criterion
SC-003 fires if any mapping below is broken.

Phase 3 US1 ships only the canonicalization-shaped properties
(P4, P5) — the ones that need neither a backend nor cryptography.
The remaining P1\/P2\/P3\/P6 properties land with each backend, which
will provide its own concrete 'Proof' and 'SetCommitment' payloads.

Citations — see "ZK.DSL.SetMembership".
-}
module ZK.DSL.Properties.SetMembership
    ( -- * Generators
      genElement
    , genNonEmptyElements
    , genSet

      -- * Phase 3 US1 properties (canonical-form only)
    , prop_canonicalization_idempotent
    , prop_empty_rejected
    ) where

import Data.ByteString qualified as BS
import Data.Word (Word8)
import Test.QuickCheck
    ( Gen
    , Property
    , arbitrary
    , forAll
    , listOf1
    , property
    , (===)
    )

import ZK.DSL.SetMembership
    ( Element (..)
    , Set
    , fromList
    , toList
    )

{- | Uniform 'Element' generator. Element bytes are built from
QuickCheck's @['Word8']@ instance, so no orphan 'Arbitrary'
for 'Data.ByteString.ByteString' is required.
-}
genElement :: Gen Element
genElement = do
    bytes <- arbitrary :: Gen [Word8]
    pure (Element (BS.pack bytes))

{- | Generator for a non-empty list of elements — the precondition
for 'fromList' to return 'Just'.
-}
genNonEmptyElements :: Gen [Element]
genNonEmptyElements = listOf1 genElement

{- | Generate a 'Set' by running 'fromList' over a non-empty input.
Filters out 'Nothing' by construction, so the generator always
produces a valid 'Set'.
-}
genSet :: Gen Set
genSet = do
    xs <- genNonEmptyElements
    maybe genSet pure (fromList xs)

{- | __P4__ — @fromList . toList . fromList ≡ fromList@.

Canonicalization (lex sort + dedup) is idempotent: running the
pipeline twice yields the same 'Set' as running it once. This is
the prerequisite every backend relies on before asserting its
commitment / proof properties.

Lean counterpart: @ZKLab.SetMembership.canonicalization@ of
@lean/ZKLab/SetMembership.lean@.
-}
prop_canonicalization_idempotent :: Property
prop_canonicalization_idempotent =
    forAll genNonEmptyElements $ \xs ->
        let once = fromList xs
            twice = fromList (maybe [] toList once)
        in  once === twice

{- | __P5__ — @fromList [] ≡ Nothing@.

Empty sets carry no membership statement; the DSL rejects them at
construction time. This is the counterpart to the Aiken and Lean
emptiness rejection and is the reason 'Set' has no public ctor.

Lean counterpart: @ZKLab.SetMembership.emptyRejected@.
-}
prop_empty_rejected :: Property
prop_empty_rejected =
    property (fromList ([] :: [Element]) === Nothing)
