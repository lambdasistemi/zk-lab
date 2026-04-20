# Contract: Property Surface (Lean ↔ QuickCheck)

**Feature**: [../spec.md](../spec.md) | **Plan**: [../plan.md](../plan.md)

Every DSL primitive ships a Lean property module and a QuickCheck
property module (constitutional principle 6b). For set membership, the
two files are:

- `lean/ZKLab/SetMembership.lean` — formal, machine-checked.
- `offchain/src/ZK/DSL/Properties/SetMembership.hs` — executable,
  randomized.

This contract pins the 1:1 mapping between them. SC-003 is satisfied
exactly when every Lean identifier below has a named Haskell
counterpart.

## Property mapping

| # | Lean identifier | Haskell identifier | Meaning |
|---|-----------------|-------------------|---------|
| P1 | `ZKLab.SetMembership.completeness` | `prop_completeness` | For every `(S, v ∈ S)`, an honest prover yields a proof that verifies against the honest commitment. |
| P2 | `ZKLab.SetMembership.soundness` | `prop_soundness` | For every `(S, v ∉ S)`, no PPT adversary with access to the public commitment produces a verifying proof except with negligible probability. |
| P3 | `ZKLab.SetMembership.zeroKnowledge` | `prop_zero_knowledge` | There exists a simulator whose output distribution on `(S, C)` is computationally indistinguishable from a real prover's transcript on `(S, v, C)`. |
| P4 | `ZKLab.SetMembership.canonicalization` | `prop_canonicalization_idempotent` | `fromList . toList . fromList ≡ fromList` (dedup + sort is idempotent) — prerequisite to the backend-level properties. |
| P5 | `ZKLab.SetMembership.emptyRejected` | `prop_empty_rejected` | `fromList [] ≡ Nothing` and no `Intention 'SetMembership` can be built on an empty set. |
| P6 | `ZKLab.SetMembership.proofUnlinkability` | `prop_proofs_unlinkable` | For the same `S` and distinct `v₁, v₂ ∈ S`, the proof distributions are computationally indistinguishable (ensemble-level; QuickCheck runs a bounded statistical test, Lean states the full ensemble claim). |

## Lean module skeleton

```lean
/-
Module:  ZKLab.SetMembership
Cites:   Goldwasser, Micali, Rackoff 1989 (10.1137/0218012)
         for the completeness / soundness / zero-knowledge
         formulations; Merkle 1987 (10.1007/3-540-48184-2_32)
         for the membership-by-path formulation; Tessaro, Zhu 2023
         (10.1007/978-3-031-30589-4_24) for the BBS+-style
         formulation.
-/
import Mathlib.Probability.ProbabilityMassFunction.Basic
import Mathlib.Probability.Distributions.Equivalence

namespace ZKLab.SetMembership

-- types (abstract; realized by backend modules)
variable (Elem : Type) (Commit : Type) (Witness : Type) (Proof : Type)

def Set := Finset Elem

theorem completeness : ... := by ...
theorem soundness    : ... := by ...
theorem zeroKnowledge : ... := by ...
theorem canonicalization : ... := by ...
theorem emptyRejected : ... := by ...
theorem proofUnlinkability : ... := by ...

end ZKLab.SetMembership
```

The file that merges in this slice states the theorems with explicit
type variables for `Elem`, `Commit`, etc., and leaves the proofs as
`sorry` — the theorems are *specifications*, not claims about any
concrete backend. Each backend PR discharges the `sorry`s for its own
instantiation.

## QuickCheck module skeleton

```haskell
module ZK.DSL.Properties.SetMembership
    ( prop_completeness
    , prop_soundness
    , prop_zero_knowledge
    , prop_canonicalization_idempotent
    , prop_empty_rejected
    , prop_proofs_unlinkable
    , genSet
    , genMember
    , genNonMember
    ) where

-- Generators (spec §Edge Cases drive the shrinkers)
genSet       :: Gen Set
genMember    :: Set -> Gen Value     -- always in the set
genNonMember :: Set -> Gen Value     -- guaranteed outside the set
```

Each `prop_*` is `forall backend. Backend s => ...`, parameterized
over the backend under test. The backend PR wires its instance into
the test suite; this spec ships the property *shapes* only.

## How SC-003 is checked

CI runs a small script (`offchain/scripts/check-property-parity.hs`)
that parses:

- every top-level `theorem`/`lemma` under
  `lean/ZKLab/SetMembership.lean`
- every top-level identifier matching `^prop_` in
  `offchain/src/ZK/DSL/Properties/SetMembership.hs`

and fails CI if the two sets are not in 1:1 correspondence (mapping
driven by the table in this file). This is the "every property has a
counterpart" check from SC-003, mechanized.

## What is deliberately absent

- No statement tied to a specific curve or commitment scheme. Those
  appear in per-backend specs.
- No performance claims. QuickCheck runs to failure on bad witnesses;
  it is not a benchmark.
- No universal-composability (UC) framing. This lab is not a UC
  library; GMR 1989's stand-alone formulations are enough.
