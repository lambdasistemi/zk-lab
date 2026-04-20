# Phase 1 Data Model: Set Membership DSL Slice

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

This document captures the DSL-level entities for set membership. It
does not describe any backend's internal representation — those live
in per-backend specs that land with each backend PR.

Entities are grouped by *role*: values the DSL author uses, types that
shape the intention, vector-store fixtures that drive every backend.
This mirrors the narrative order (Intention → Semantics →
Implementation).

## Intention-level entities

### Element

- **What it represents**: A single byte string that can appear in a
  set. Kept as bytes (not text) because backends commit to raw bytes.
- **Type**: `newtype Element = Element ByteString`
- **Invariants**:
  - Bytes are uninterpreted. No encoding assumptions (no UTF-8
    requirement).
  - Length is unbounded at the DSL layer; each backend may cap it and
    report the cap in the parity matrix.

### Set

- **What it represents**: A finite, deduplicated collection of
  `Element`s — the secret pre-image the prover knows.
- **Type**: `newtype Set = Set (Data.Set.Set Element)`
- **Invariants**:
  - No duplicates (enforced by `Data.Set.Set`).
  - The DSL exposes `fromList :: [Element] -> Set` which sorts and
    dedupes per D-05 (see [research.md](./research.md)).
  - Size ≥ 1. Empty sets are rejected at construction
    (`fromList []` returns `Nothing`), matching the edge case in the
    spec.

### SetCommitment

- **What it represents**: The verifier-visible binding to a specific
  `Set`. Opaque at the DSL layer; each backend refines it.
- **Type**: `newtype SetCommitment (s :: BackendTag) = SetCommitment ByteString`
- **Invariants**:
  - Short enough to ship on-chain as a Plutus datum (constitutional
    principle 3). Actual size is a backend concern.
  - Binds to the *canonicalized* set, not the raw input list.

### Value

- **What it represents**: The prover's private witness element —
  the one it claims is a member.
- **Type**: `newtype Value = Value Element` (distinct from `Element`
  to prevent mixing the witness with a set-element in APIs).
- **Invariants**:
  - Not present in any verifier input; never leaves the off-chain
    prover.

### Intention

- **What it represents**: The DSL-level statement "I know a value that
  is a member of the set committed by `C`". Parameterized by a
  `StatementFamily` tag so it is extensible without breaking existing
  rows.
- **Type**:
  ```haskell
  data StatementFamily = SetMembership | ...

  data Intention (f :: StatementFamily) where
      SetMember
          :: Value
          -> SetCommitment s
          -> Intention 'SetMembership
  ```
- **Invariants**:
  - Constructors never mention curves, arithmetizations, or backend
    setups (FR-001).
  - The `SetCommitment s` phantom tag must match the backend that
    later interprets the intention — enforced at compile time.

### Witness

- **What it represents**: Auxiliary off-chain data a backend needs in
  addition to the `Value`. For set membership, typical shapes are a
  Merkle path (Groth16/Halo2) or a BBS+ disclosure record. The DSL
  layer does not name these — it exposes a type family.
- **Type**:
  ```haskell
  type family Witness (f :: StatementFamily) (s :: BackendTag)
  ```
- **Invariants**:
  - Must be computable from `(Value, Set)` alone (FR-003). No external
    state, no random oracle queries outside the backend's own
    construction.
  - Backends that need no witness define the instance as `()`.

### Proof

- **What it represents**: The bit string produced by the off-chain
  prover and consumed by both verifiers.
- **Type**: `newtype Proof (s :: BackendTag) = Proof ByteString`
- **Invariants**:
  - Opaque to the DSL user. Each backend's on-chain verifier module
    decodes it.

### Verdict

- **What it represents**: The binary outcome of verification.
- **Type**: `data Verdict = Accept | Reject deriving (Eq, Show)`
- **Invariants**:
  - Soundness: a `Reject` verdict on a tampering vector is *required*
    by the test harness. A backend returning `Accept` on a tampering
    vector fails its test (FR-008, constitutional principle 6).

## Vector-store entities

These correspond one-to-one to the files in
`vectors/set-membership/`. Their JSON schema is captured in
[contracts/vectors.md](./contracts/vectors.md); the Haskell-side
decoders live in `offchain/src/ZK/Vectors/SetMembership.hs`.

### PositiveCase

- **What it represents**: A valid (set, value ∈ set, honest proof
  expectation) triple. Does not include the proof itself — that is
  backend-specific and regenerated per-backend; the test harness
  asserts `Accept`.
- **Fields** (see `contracts/vectors.md` for JSON types):
  - `name :: Text`
  - `set :: [Element]` (raw input; may contain duplicates — the test
    harness canonicalizes before comparing)
  - `canonicalSet :: [Element]` (expected canonicalized form; checked
    before any backend runs)
  - `value :: Value`
  - `expectedVerdict :: Verdict` (always `Accept`)

### TamperingCase

- **What it represents**: A deliberate perturbation of a positive case
  with an expected `Reject` verdict.
- **Fields**:
  - `name :: Text`
  - `baseCase :: Text` (references a `PositiveCase.name`)
  - `mutation :: Mutation` (sum type, see below)
  - `expectedVerdict :: Verdict` (always `Reject`)

### Mutation

- **What it represents**: The class of tampering applied.
- **Type** (Haskell ADT; JSON-discriminated):
  ```haskell
  data Mutation
      = NonMember Value             -- swap in a value not in the set
      | WrongCommitment             -- use a commitment from another set
      | FlippedProofBit Int         -- flip bit i of the proof
      | ReplayAcrossSets            -- valid proof for set S1 vs commit of S2
  ```
- **Invariants**:
  - Every `Mutation` constructor has at least one backend for which
    the tampering is constructible; a vector whose tampering cannot
    be realized by any backend is a vector bug.

## Parity-matrix-level entities

### ParityRow

- **What it represents**: One row of the cross-cutting parity matrix
  rendered at `docs/dsl/parity-matrix.md` (SC-004).
- **Fields**:
  - `primitive :: Text` (for this spec: `"set-membership"`)
  - `backend :: Backend` (`Groth16 | BBSPlus | Halo2`)
  - `status :: ParityStatus` (`Complete ✅ | Gap ⚠️ Reason | Missing ❌`)
  - `note :: Maybe Text` (optional free-form pointer to the backend
    PR, if any)
- **Invariants**:
  - No blank cells (SC-004).
  - All three backends start at `Missing ❌` when this spec merges;
    subsequent backend PRs update their own row.

## Relationships

```text
                 ┌────────────────────┐
                 │   Element (bytes)  │
                 └──────────┬─────────┘
                            │ dedup + sort
                            ▼
┌──────────┐         ┌──────────┐         ┌──────────────────────┐
│  Value   │────────▶│   Set    │────────▶│  SetCommitment s     │
└────┬─────┘         └────┬─────┘         └──────────┬───────────┘
     │                    │  Witness f s              │
     │                    └───────────────────────┐   │
     │                                            ▼   │
     │                                      ┌──────────────┐
     └────────────────────────────────────▶ │  Intention f │
                                             └──────┬───────┘
                                                    │
                                                    │ (backend prover)
                                                    ▼
                                              ┌──────────┐
                                              │ Proof s  │
                                              └────┬─────┘
                                                   │ (on-chain
                                                   │  + off-chain
                                                   │  verifier)
                                                   ▼
                                              ┌──────────┐
                                              │ Verdict  │
                                              └──────────┘
```

## State transitions

The DSL slice has no runtime state. Canonicalization is a pure
function; `fromList` is pure; `SetMember` is a constructor. No backend
code runs here. State transitions (prover setup → proving → verifying)
appear with the first backend PR and are documented there.
