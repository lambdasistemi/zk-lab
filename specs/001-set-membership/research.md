# Phase 0 Research: Set Membership DSL Slice

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

No `NEEDS CLARIFICATION` markers exist in the Technical Context. This
document records the non-obvious *technology* decisions that shape the
DSL slice and the alternatives that were considered and rejected.

## Decisions

### D-01. DSL embedding: GADT with phantom-tagged result type

**Decision**: Represent the DSL as a single GADT parameterized by a
phantom "statement family" tag:

```haskell
data Intention (s :: StatementFamily) where
    SetMember
        :: Value
        -> SetCommitment s
        -> Intention 'SetMembership
```

**Rationale**: The constitution demands feature parity *as a design
target*: adding a new primitive must not force a redesign. A GADT
admits new constructors without breaking the existing ones; the
phantom tag lets a backend compile only the intention shapes it
supports, with a type error — not a runtime "not implemented" — when a
backend is asked to realize an unsupported primitive. This matches
principle 2 (parity is a design target, gaps are first-class).

**Alternatives considered**:

- *Typeclass-per-primitive* (`class SetMembership backend where ...`).
  Rejected: forces a cartesian product of classes × backends and
  fragments the DSL into per-primitive modules. Onboarding cost
  violates SC-001 (30-minute ramp).
- *Free monad / free applicative*. Rejected: over-general. The DSL is
  not a program, it is a statement. Sequencing has no meaning yet;
  combinators will be a later spec.
- *Tagless-final*. Rejected for this slice: would require every
  backend to instantiate the interpreter type before any intention
  compiles, which drags the first-backend PR into this one.

### D-02. Set commitment type: opaque, phantom-tagged

**Decision**: `SetCommitment s` is an opaque `newtype` over a
`ByteString`, parameterized by a backend tag `s`. The DSL user sees a
single type; the backend refines it to Merkle root / Pedersen vector
commitment / BBS+ signature when it compiles the intention.

**Rationale**: FR-002 requires the raw set to never reach the
verifier; only the commitment does. Keeping `SetCommitment` opaque at
the DSL layer enforces this at the type system. The phantom tag
matches D-01 and lets the type checker reject mixing commitments
across backends.

**Alternatives considered**:

- *Sum type of commitment schemes*. Rejected: leaks backend choice
  into the DSL surface (violates FR-001).
- *Type family `CommitmentFor backend`*. Preserved as an *internal*
  tool in `offchain/src/ZK/Backend/Class.hs` (a future file). The DSL
  user continues to see the opaque `SetCommitment s`.

### D-03. Formal property language: Lean 4 + Mathlib4

**Decision**: Lean 4 with Mathlib4 as the formal property substrate.
Property file: `lean/ZKLab/SetMembership.lean`. Build via `lake`.

**Rationale**: Constitution principle 6b names Lean explicitly.
Mathlib4 already carries probability ensembles, simulators, and
extractor signatures needed to state ZK, so the file stays under ~80
LOC. Lean 4's tooling (lake, Mathlib cache) runs cleanly in Nix.

**Alternatives considered**:

- *Coq*. Rejected: constitution says Lean; switching would require a
  constitutional amendment and broader agreement.
- *Agda*. Rejected: smaller probability library, higher maintenance
  cost.
- *Isabelle/HOL*. Rejected: tooling does not fit the Nix-first
  workflow as ergonomically.

### D-04. Vector store schema: flat JSON, one file per case

**Decision**: Vectors live as separate JSON files under `positive/`
and `tampering/` subdirectories. Each file has a flat object with the
fields defined in `contracts/vectors.md`. A sibling `schema.json`
(JSON Schema 2020-12) describes the shape and is validated in CI.

**Rationale**: FR-004 requires a single schema. Per-file layout means
adding a vector is a single-file diff — no merge conflicts on a mega-
JSON. JSON Schema validation in CI guards against schema drift
without pulling in a heavier framework. `aeson` parses it trivially
from Haskell; any other language can too.

**Alternatives considered**:

- *Single `vectors.json`*. Rejected: merge-conflict magnet when
  multiple backend PRs add tampering cases in parallel.
- *YAML*. Rejected: JSON is more interoperable (Haskell, Rust, Lean
  metaprograms); YAML offers no advantage here.
- *Protobuf / CBOR*. Rejected: premature; the store is development-
  time only and human-editable diffs matter.

### D-05. Canonicalization: lexicographic sort + dedup, SHA-256-tagged

**Decision**: Before committing a set, the DSL canonicalizes: sort
elements by lexicographic byte order; drop duplicates; hash the
concatenation with a domain-separation tag (`"zk-lab/set-membership/v1"`)
using SHA-256 to produce a canonicalization-check value that ships
alongside the commitment in the vector store.

**Rationale**: The edge case "duplicate elements in the set" (spec
§Edge Cases) requires deterministic dedup. Lexicographic sort is
deterministic, backend-independent, and trivial to re-implement in
Lean and Aiken. The SHA-256 canonicalization tag is not the
cryptographic commitment — each backend picks its own — but it lets
vectors assert "every backend should have reached this canonical
representation before applying its own commitment scheme," catching
canonicalization divergence as a test failure rather than a silent
bug.

**Alternatives considered**:

- *Insertion-order-preserving representation*. Rejected: makes the
  commitment depend on input order; two provers starting from
  semantically equal sets would produce incompatible commitments.
- *Multiset (with multiplicities)*. Rejected: spec §Out of Scope says
  multisets get their own primitive.
- *Poseidon or Blake3 for the canonicalization tag*. Rejected: SHA-256
  is the lowest-common-denominator hash; every backend has it
  natively. The canonicalization hash is not on-chain so its
  performance does not matter.

## Open questions deferred to backend PRs

These are recorded here so backend authors know they are expected and
not forgotten:

- Merkle tree arity (binary vs wider) for the Groth16 backend row.
- BBS+ generator derivation ritual (per-set vs per-verifier-instance).
- Halo2 PLONKish custom gate budget vs Plutus budget. Likely a gap in
  the parity matrix at first landing.

None of these block the DSL-only slice.

## References

- Merkle, R. C. (1988). *A Digital Signature Based on a Conventional
  Encryption Function.* CRYPTO '87.
  [DOI:10.1007/3-540-48184-2_32](https://doi.org/10.1007/3-540-48184-2_32).
- Tessaro, S. & Zhu, C. (2023). *Revisiting BBS Signatures.* EUROCRYPT
  2023.
  [DOI:10.1007/978-3-031-30589-4_24](https://doi.org/10.1007/978-3-031-30589-4_24).
- Goldwasser, S., Micali, S. & Rackoff, C. (1989). *The Knowledge
  Complexity of Interactive Proof Systems.* SIAM J. Computing.
  [DOI:10.1137/0218012](https://doi.org/10.1137/0218012).
