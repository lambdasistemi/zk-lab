# zk-lab Constitution

## Purpose

A laboratory for expressing privacy-preserving statements at a *high level*
and compiling them to Plutus-verifiable proofs. The DSL is the product;
backends are plumbing.

The repo is structured along one axis: **intention → implementation**.
First you write what you want to prove. Then backends — Groth16, BBS+,
Halo2 — compete to realize it. Feature parity across backends is a design
target, not a nice-to-have.

The first two backends are imported from existing work: the Groth16
pipeline from `harvest-015` and the BBS+ pipeline from `cardano-bbs`.
Halo2 is the forward direction.

## North Star

Write the statement once in the DSL; pick a backend; get an on-chain
verifier (Plutus) and an off-chain prover (Haskell). The DSL user should
never need to know which curve, which arithmetization, or which setup
ritual their proof runs through.

## Narrative Order

All documentation, all PRs, and all planning artifacts follow the same
order:

1. **Intention.** What statement is being expressed in the DSL?
2. **Semantics.** What is the user-visible meaning and the parity
   contract across backends?
3. **Implementation.** How does each backend realize it?

Never invert. An implementation PR with no DSL story is rejected. A
backend feature without a DSL primitive is premature.

## Core Principles

### 1. Intention, not circuits
The DSL expresses *what* is being proved (membership, range, selective
disclosure, threshold), not *how* constraints are wired. Circuit details
are a backend concern. A DSL user should never touch R1CS, PLONK custom
gates, or BBS+ generator derivation.

### 2. Feature parity as a design target
Every DSL primitive must be implementable on every supported backend, or
the primitive is rejected. Parity is enforced by a parity matrix in docs
and CI: statement × backend → {works, gap, incompatible}. Gaps are bugs,
not footnotes.

### 3. Plutus is the on-chain target
Every backend must emit an on-chain verifier usable as a Plutus script.
Backends that cannot meet Plutus budget constraints for a given statement
are reported as gaps in the parity matrix — not silently dropped.

### 4. Import, don't reinvent
Groth16 and BBS+ cores are *copied* from `harvest-015` and `cardano-bbs`
with attribution. They are reshaped to fit the DSL's backend interface,
not rewritten. The lab inherits their working cryptography; it adds the
layer above.

### 5. FFI is the cryptography boundary
Cryptography lives in Rust crates with C ABIs under
`offchain/cbits/<backend>-ffi/`. Haskell wraps them and owns types,
serialization, error handling. The boundary is narrow by design — adding
a DSL primitive should not grow the FFI surface unless a new
cryptographic operation is genuinely needed.

### 6. Correctness before performance
Every backend implementation of every statement ships with at least one
negative-witness test: a prover call with a bad witness that must fail
verification. Soundness bugs in ZK are silent. Positive-only tests are
forbidden.

### 6a. Shared test vectors
Every statement has a single, canonical test-vector store consumed by
every backend. The store lives under `vectors/<statement>/` and is
format-agnostic JSON: inputs, expected witness, expected verdicts for
a set of tampering cases. A new backend proves parity by passing the
same vectors as the existing backends. Vectors are the ground truth —
divergent backend-local fixtures are a smell.

### 6b. Properties, dual-specified
Every DSL primitive ships a property spec in both **Lean** (formal,
machine-checked) and **QuickCheck** (randomized, executable). Lean
guards meaning; QuickCheck guards every backend against it at test
time. Lean properties live under `lean/ZKLab/<Statement>.lean`;
QuickCheck generators live alongside the DSL types.

### 7. Culture is first-class
The repo includes a semantic graph (Turtle/RDF) of zero-knowledge
concepts that goes deep into culture, abstractions, and real-life
challenges. It is a living artifact, updated with every experiment.
Teaching and situating the work matters as much as building it.

### 7a. Steal, always cite
We freely take from existing materials — explanations, diagrams,
definitions, phrasings, code — whenever doing so produces better work
than reinventing. In exchange, every borrowed element carries an
explicit citation to its source. Uncited borrowing is a bug.
Attribution includes: paper/book with DOI or arXiv id, author(s),
year, and a short note on what was taken and why. Applies to prose,
mathematical definitions, diagrams (with "after X, year"), and code
(file-level header pointing to the source commit).

### 8. Reproducible builds
Nix-first. Rust toolchain and Haskell index-state pinned. `cargo` is
driven through Nix in CI, never invoked ad-hoc. Lockfiles committed.

### 9. Honest documentation
MkDocs site is a logbook. Record what worked, what didn't, and why. The
parity matrix, prover/verifier benchmarks, and on-chain budget numbers
are published artifacts — not buried in commit messages. Negative
results are first-class.

### 10. No production recommendations
Nothing here is production-ready. Toy trusted setups only; no reused
`.ptau`. Every statement's README states this. This is a learning repo.

## Stack

- **DSL:** Haskell-embedded, intention-first.
- **Backends:** Groth16 (arkworks), BBS+ (zkryptium), Halo2 (PSE) —
  each behind a uniform backend interface.
- **FFI:** Rust crates with C ABIs.
- **Onchain target:** Plutus. Aiken is the authoring language.
- **Chain I/O:** `cardano-node-clients` only. No direct `cardano-api`.
- **Build:** Nix flakes, haskell.nix, cargo-via-nix, justfile.
- **CI runner:** `lambdasistemi` self-hosted NixOS.

## Domain Constraints

- **Groth16 backend:** arkworks (`ark-groth16`). Curve: BN254.
- **BBS+ backend:** zkryptium. Curve: BLS12-381.
- **Halo2 backend:** PSE fork. Plutus verifier story is open research;
  honestly tracked in the parity matrix.
- **Aiken** is the authoring language for verifiers; compiled Plutus is
  the artifact.
- **Circom** permitted only as an intermediate Groth16 compilation
  target behind the DSL — never as the user-facing interface.

## Workflow

- **Layout-first stgit** per feature: one stack of vertical commits,
  every commit compiles and tests pass.
- **One DSL feature or one backend feature per PR.** Changes touching
  the DSL *and* a backend must either add the primitive on every
  backend in the same PR, or explicitly register the gap in the parity
  matrix.
- **Conventional commits.** `feat:`, `fix:`, `docs:`, `bench:`, `port:`
  (for copy-overs from source repos), `parity:` (for matrix updates).
- **CI gates:** fourmolu, cabal-fmt, rustfmt, aiken fmt, hlint, clippy,
  build, unit tests, parity check, docs build (`--strict`).
- **Benchmarks:** in-repo tables, hardware noted. Prover time, proof
  size, verifier Plutus budget.

## Governance

The constitution gates `/speckit.specify` planning. Amendments require
a PR stating the driver and updating affected experiments and the
parity matrix. Constitution/practice drift is a bug.

**Version**: 0.1.0 | **Ratified**: 2026-04-18 | **Last Amended**: 2026-04-18
