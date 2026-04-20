{- |
Module      : ZK.DSL.Properties.SetMembership
Description : QuickCheck counterparts of the Lean set-membership properties.
Copyright   : (c) lambdasistemi, 2026
License     : Apache-2.0

Executable, randomized mirror of @lean/ZKLab/SetMembership.lean@.
Property names correspond 1:1 to the Lean identifiers documented in
@specs/001-set-membership/contracts/properties.md@.  Success
criterion SC-003 is mechanized by
@offchain/scripts/check-property-parity.sh@: CI fails if the Lean
parity section and this module drift apart.

P4 and P5 are purely structural (canonicalization) and have
exercisable bodies right here.  P1, P2, P3, P6 depend on a backend
and ship as /shape/ properties with placeholder bodies; the first
backend PR replaces the bodies with the real witness-and-verifier
calls.  Keeping the names in this module guarantees SC-003 stays
green between backends.

Citations (principle 7a; registry in @docs\/dsl\/citations.md@):

* __GMR 1989__ — Goldwasser, Micali, Rackoff,
  /The Knowledge Complexity of Interactive Proof Systems/.
  SIAM J. Comput. 18(1) (1989).  DOI 10.1137\/0218012.
  Supplies the P1 (completeness), P2 (soundness) and
  P3 (zero-knowledge) formulations.
* __Merkle 1987__ — /A Digital Signature Based on a Conventional
  Encryption Function/.  CRYPTO '87.
  DOI 10.1007\/3-540-48184-2_32.  Membership-by-path motivation
  behind P6 (unlinkability).
* __Tessaro-Zhu 2023__ — /Revisiting BBS Signatures/.
  EUROCRYPT 2023.  DOI 10.1007\/978-3-031-30589-4_24.
  BBS+-style set-commitment formulation; another reading of P6.
-}
module ZK.DSL.Properties.SetMembership
    ( -- * Generators
      genElement
    , genNonEmptyElements
    , genSet

      -- * Structural properties (backend-free, P4 and P5)
    , prop_canonicalization_idempotent
    , prop_empty_rejected

      -- * Backend-dependent properties (placeholder shapes)
    , prop_completeness
    , prop_soundness
    , prop_zero_knowledge
    , prop_proofs_unlinkable
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

{- | Uniform 'Element' generator.  Element bytes are built from
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
pipeline twice yields the same 'Set' as running it once.  This is
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
construction time.  This is the counterpart to the Aiken and Lean
emptiness rejection and is the reason 'Set' has no public ctor.

Lean counterpart: @ZKLab.SetMembership.emptyRejected@.
-}
prop_empty_rejected :: Property
prop_empty_rejected =
    property (fromList ([] :: [Element]) === Nothing)

{- | __P1__ — completeness.

Shape: for every @(S, v ∈ S)@, an honest prover yields a proof
that verifies against the honest commitment.  The body is
@property True@ until a backend ships concrete @prove@ and
@verify@ functions; the property's /existence/ is what SC-003
guards.

Lean counterpart: @ZKLab.SetMembership.completeness@.  See GMR
1989 §completeness.
-}
prop_completeness :: Property
prop_completeness =
    -- NOTE: stub for bisect-safety, body filled by the first backend PR.
    property True

{- | __P2__ — soundness.

Shape: for every @(S, v ∉ S)@, no PPT adversary with access to
the public commitment produces a verifying proof except with
negligible probability.  The current body is the degenerate case
— a verifier stub that rejects every input — so the property is
trivially true.  Backend PRs replace the stub verifier with the
real one and the property becomes meaningful.

Lean counterpart: @ZKLab.SetMembership.soundness@.  See GMR 1989
§soundness.
-}
prop_soundness :: Property
prop_soundness =
    -- NOTE: stub for bisect-safety, body filled by the first backend PR.
    property True

{- | __P3__ — zero-knowledge.

Shape: there exists a simulator whose output distribution on
@(S, C)@ is computationally indistinguishable from a real
prover's transcript on @(S, v, C)@.  In the DSL-only slice there
is no transcript to sample from, so the body is @property True@
and the name is what the parity script checks.

Lean counterpart: @ZKLab.SetMembership.zeroKnowledge@.  See
GMR 1989 §zero-knowledge.
-}
prop_zero_knowledge :: Property
prop_zero_knowledge =
    -- NOTE: stub for bisect-safety, body filled by the first backend PR.
    property True

{- | __P6__ — proof unlinkability.

Shape: for the same @S@ and distinct @v₁, v₂ ∈ S@, the proof
distributions are computationally indistinguishable
(ensemble-level; QuickCheck runs a bounded statistical test,
Lean states the full ensemble claim).  Placeholder body as with
P1/P2/P3 until a backend instantiates it.

Lean counterpart: @ZKLab.SetMembership.proofUnlinkability@.
See Merkle 1987 (membership-by-path) and Tessaro-Zhu 2023
(BBS+-style) for the two natural readings.
-}
prop_proofs_unlinkable :: Property
prop_proofs_unlinkable =
    -- NOTE: stub for bisect-safety, body filled by the first backend PR.
    property True
