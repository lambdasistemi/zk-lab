# Feature Specification: Set Membership

**Feature Branch**: `001-set-membership`
**Created**: 2026-04-19
**Status**: Draft
**Input**: User description: "Set membership: prove v is in a committed set S without revealing v or the other elements of S. First DSL primitive. Parity target: Groth16, BBS+, Halo2."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Prove a value belongs to a committed set (Priority: P1)

A DSL author expresses, in a single sentence, that they know a value
that is a member of a publicly committed set. They pick a backend.
They receive an off-chain prover that consumes their secret value and
the set's representation, and an on-chain verifier (Plutus) that
consumes the proof plus the public set commitment. Nothing else about
the value or the other set elements is revealed.

**Why this priority**: This is the smallest non-trivial statement in
the lab. It exercises every architectural seam — intention type,
shared test vectors, Lean + QuickCheck property pair, backend
interface, Plutus verifier — without needing any composition of
primitives. The constitution gates everything on the DSL being the
surface: shipping the first primitive is what makes the DSL real.

**Independent Test**: A fresh contributor writes `member v in S` in the
DSL, picks `Groth16` (once available), runs the canonical test vectors
under `vectors/set-membership/`, and sees every positive case verify
and every negative case reject. No R1CS, no arithmetization, no curve
choice appears in their code or in the vectors.

**Acceptance Scenarios**:

1. **Given** a committed finite set `S` and a secret value `v ∈ S`,
   **When** the prover runs the DSL intention against any parity-complete
   backend, **Then** the resulting proof verifies against the on-chain
   verifier for the same backend and the same public commitment to `S`.
2. **Given** a committed set `S` and a value `v ∉ S`, **When** the
   prover attempts to produce a proof, **Then** no honest prover can
   produce a verifying proof (soundness), and any attempt to verify a
   tampered proof against the real commitment rejects.
3. **Given** two different sets `S₁` and `S₂` with the same committed
   element `v`, **When** a verifier receives proofs for both, **Then**
   the verifier cannot link them (zero-knowledge) — the proofs are
   indistinguishable from proofs about an honest simulator.

---

### User Story 2 — Shared test vectors drive every backend (Priority: P1)

A backend implementer adds (or ports) a new backend. Before they write
any cryptography, they read the canonical test-vector store under
`vectors/set-membership/`. Their backend is "parity-complete" for this
primitive iff it passes every vector — positive witnesses verify,
tampering cases reject, and the backend reports honest Plutus budget
numbers (or registers a gap).

**Why this priority**: Constitution principle 6a says vectors are the
ground truth. If the first primitive does not ship with a vectors store,
the constitution is decorative. Bundling the store with the spec makes
it impossible to add a backend without honoring parity.

**Independent Test**: Delete every backend's local fixtures; point the
backend test suite at `vectors/set-membership/`; all parity-complete
backends still pass.

**Acceptance Scenarios**:

1. **Given** the `vectors/set-membership/` store, **When** a backend's
   test suite runs, **Then** it executes every vector without any
   backend-local fixture.
2. **Given** a new tampering case is added to the store, **When**
   backends re-run tests, **Then** every parity-complete backend
   rejects the tampered proof; failure to reject is a backend bug, not
   a vector bug.

---

### User Story 3 — Properties are dual-specified in Lean and QuickCheck (Priority: P1)

A reviewer asks "what does this primitive actually mean?" The answer
is two files: `lean/ZKLab/SetMembership.lean` (formal, machine-checked
statement of completeness, soundness, and zero-knowledge) and
`offchain/src/ZK/DSL/Properties/SetMembership.hs` (executable QuickCheck
generators plus the same properties in testable form). The Lean file
is the source of truth; QuickCheck is the continuous check every
backend runs.

**Why this priority**: Constitution principle 6b. A primitive without
a dual-spec is a primitive without meaning. Shipping both files in the
same PR prevents the Haskell side drifting from the formal statement.

**Independent Test**: Review the Lean file and confirm it types; read
the QuickCheck file and confirm each Lean property has a named Haskell
counterpart.

**Acceptance Scenarios**:

1. **Given** the Lean file, **When** a reader inspects it, **Then**
   soundness, completeness, and zero-knowledge are stated as
   propositions with explicit references to the inputs, the
   commitment, and the verification relation.
2. **Given** the QuickCheck file, **When** a backend test suite runs
   it, **Then** each property is exercised on generated vectors and
   the backend under test. Failure is a backend bug or a vector bug,
   never a silent pass.

---

### Edge Cases

- **Empty set**: Proving membership in an empty set MUST be rejected
  by the DSL at intention-construction time (no proof should even be
  attempted). Tested as a negative vector.
- **Singleton set**: Supported. The backend MUST NOT leak that the set
  has only one element — proof indistinguishability is a zero-knowledge
  requirement.
- **Duplicate elements in the set**: The committed set is a set
  (no duplicates). If the input sequence has duplicates, the DSL MUST
  canonicalize (dedupe) before committing. Tested as a vector where
  the raw input has duplicates and the canonical commitment matches.
- **Maximum set size**: The DSL places no abstract upper bound. Each
  backend MAY register a practical cap in the parity matrix (e.g.
  Groth16 Merkle depth 20 = 2^20 leaves). Exceeding a backend cap is a
  gap, not a crash.
- **Proof replay across sets**: A valid proof against commitment
  `C₁` MUST NOT verify against `C₂ ≠ C₁`. Tested as a tampering case
  in the vectors.
- **Proof replay within a set**: A prover producing proofs for `v₁`
  and `v₂` from the same set MUST produce proofs that are unlinkable.
  Tested as a distributional indistinguishability property in
  QuickCheck (Lean states it as an ensemble-level property).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The DSL MUST expose a single user-facing construct for
  set membership; its surface syntax MUST NOT reference circuits,
  arithmetization, curves, or backend-specific setup rituals.
- **FR-002**: The DSL MUST require a public set commitment as the
  verifier's only set-related input; the raw set MUST NOT be required
  by the verifier.
- **FR-003**: The DSL MUST accept, as the prover's private input, the
  value `v` plus whatever auxiliary witness the backend requires (e.g.
  a Merkle path). The auxiliary witness computation MUST be derivable
  from the public set representation and `v` alone, without further
  prover state.
- **FR-004**: A canonical shared test-vector store MUST live at
  `vectors/set-membership/`. Its schema (JSON) MUST include: the input
  set, the committed representation, one or more positive witnesses,
  and a catalogue of tampering cases with expected verdicts.
- **FR-005**: The `vectors/set-membership/` store MUST be the single
  source of truth consumed by every backend's test suite. Backend-local
  fixtures for this primitive MUST NOT exist.
- **FR-006**: A Lean property module MUST exist at
  `lean/ZKLab/SetMembership.lean` stating completeness, soundness, and
  zero-knowledge as propositions that reference only the DSL-level
  entities, not a specific backend.
- **FR-007**: A QuickCheck property module MUST exist alongside the
  DSL types and MUST implement each Lean property as an executable
  generator-driven check. Its API MUST be importable by every backend's
  test suite.
- **FR-008**: Every backend MUST appear in the parity matrix with a
  row for this primitive, marked one of: ✅ (all vectors pass,
  Plutus-deployable), ⚠️ (vectors pass but Plutus budget exceeds
  limits — registered as a gap), or ❌ (not implemented).
- **FR-009**: The spec MUST cite every borrowed formulation (Merkle
  path membership, BBS+ signature proof-of-knowledge, etc.) per
  constitution principle 7a. Uncited borrowings are bugs.
- **FR-010**: The spec MUST name the Plutus verifier module skeleton
  (Aiken authoring, file under `onchain/verifiers/set_membership/`)
  even though no verifier code ships in this spec. The name must exist
  so downstream plan/tasks commits are bisect-safe.
- **FR-011**: Nothing in this spec or downstream artifacts MAY imply
  production use. Every README touched by this slice MUST state
  "experimental, toy trusted setups only" per constitution principle 10.

### Key Entities

- **Set (S)**: A finite, deduplicated collection of byte strings. Not
  required on-chain. Used off-chain by the prover to compute the
  auxiliary witness.
- **Commitment (C)**: A short binary digest that binds the verifier to
  a specific `S`. The exact commitment scheme is a backend choice
  (Merkle root, Pedersen vector commitment, BBS+ signature over the
  set) and MUST be opaque to the DSL user; the parity matrix records
  what each backend uses.
- **Value (v)**: The prover's private witness element. Never revealed.
- **Proof (π)**: A backend-specific bitstring produced by the prover,
  consumed by the off-chain and on-chain verifiers.
- **Intention**: The DSL-level expression "`v` is a member of the set
  committed by `C`". Parameterized by nothing except the types of `v`
  and the commitment; backends plug in at compile time.
- **Parity matrix row**: One row per (primitive × backend). For this
  spec, the primitive is `set-membership` and the backends are
  `Groth16`, `BBS+`, `Halo2`. Every row begins at ❌ and is updated as
  backends land.
- **Tampering case**: A vector-store entry describing a mutation of a
  positive witness (swap commitment, flip a bit in the proof, replace
  `v` with a non-member, etc.) and the expected verdict (always
  "reject"). Every backend's test suite MUST execute every tampering
  case.
- **Verifier module skeleton**: A named directory for the on-chain
  verifier. Contains no code yet; its existence anchors downstream
  implementation commits so each remains bisect-safe under
  `mkdocs --strict` and cabal build.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new contributor can, within 30 minutes of reading the
  DSL docs, write a `member v in S` intention and point it at the
  shared test vectors without ever opening a backend-specific file.
- **SC-002**: Every parity-complete backend passes 100% of the shared
  vectors — positive cases verify, every tampering case rejects — with
  no backend-local fixtures.
- **SC-003**: For every property stated in
  `lean/ZKLab/SetMembership.lean`, there is a named QuickCheck property
  in the Haskell test module that tests the same statement. The
  mapping is 1:1.
- **SC-004**: The parity matrix renders in the docs site
  ([lambdasistemi.github.io/zk-lab/dsl/parity-matrix/](https://lambdasistemi.github.io/zk-lab/dsl/parity-matrix/))
  with a row for `set-membership` and columns for all three backends,
  each marked explicitly (no blank cells).
- **SC-005**: Any PR that adds a backend implementation of set
  membership can be reviewed against this spec in under one hour by
  someone who has not seen the PR before — because the contract
  (vectors + properties) is already fully specified.

## Assumptions

- Backends ship in separate PRs. This spec is DSL-only; it does not
  imply any backend will land in the same merge train.
- The Plutus verifier skeleton is a directory and module name only.
  Downstream specs (`/speckit.plan`, `/speckit.tasks`) turn it into
  real Aiken code.
- "Set" is pragmatic (finite, deduplicated bytes) rather than
  categorical. If future primitives need multisets or ordered
  collections, they get their own spec.
- The vector-store format is JSON. The content is format-agnostic only
  in the sense that backends must consume it without reshaping; the
  on-disk encoding is JSON for tooling reasons.
- The Lean file may use standard Mathlib definitions of probabilistic
  machines, simulators, and extractors. It need not reinvent them.
- Citations live in the spec and in file-level headers of the Lean and
  QuickCheck modules, not in a separate bibliography page. Every
  borrowed formulation carries paper title, authors, year, and DOI or
  arXiv id.

## Out of Scope

- Any Rust FFI or backend cryptography.
- Any concrete circuit, R1CS, PLONK gate, or arithmetization.
- Any benchmark numbers. Prover time, proof size, and Plutus budget
  are reported once a backend lands; they are not part of this spec.
- Multi-set, ordered-set, or range-membership variants.
- Set updates (adding or removing members after the commitment is
  published). If needed, they get a separate primitive spec.
- Composition with other primitives (AND/OR of statements). Handled
  by a later spec on combinators.

## Citations

- **Merkle tree membership**: Merkle, R. C. (1988). *A Digital Signature
  Based on a Conventional Encryption Function.* CRYPTO '87, LNCS 293,
  pp. 369–378.
  [DOI:10.1007/3-540-48184-2_32](https://doi.org/10.1007/3-540-48184-2_32).
  Standard formulation borrowed for Groth16/Halo2 backend rows.
- **BBS+ proof of knowledge over a committed set**: Tessaro, S. & Zhu,
  C. (2023). *Revisiting BBS Signatures.* EUROCRYPT 2023, LNCS 14008.
  [DOI:10.1007/978-3-031-30589-4_24](https://doi.org/10.1007/978-3-031-30589-4_24).
  Selective-disclosure machinery adapted for set membership.
- **Zero-knowledge, soundness, completeness definitions**: Goldwasser,
  S., Micali, S. & Rackoff, C. (1989). *The Knowledge Complexity of
  Interactive Proof Systems.* SIAM J. Computing, 18(1), 186–208.
  [DOI:10.1137/0218012](https://doi.org/10.1137/0218012). Used by the
  Lean property module as the canonical formulation.
