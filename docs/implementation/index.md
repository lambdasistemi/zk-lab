# Implementation

Second, not first. The DSL is where statements live; implementation
is how they run.

This section describes the plumbing:

- **[Groth16 backend](groth16.md)** — arkworks via Rust FFI.
  Ported from `harvest-015`.
- **[BBS+ backend](bbs.md)** — zkryptium via Rust FFI. Ported from
  `cardano-bbs`.
- **[Halo2 backend](halo2.md)** — PSE via Rust FFI. New; Plutus
  verifier is open research.
- **[Aiken verifiers](aiken.md)** — on-chain verifiers in Aiken.
  One per backend, shared shapes.
- **[cardano-node-clients](chain-io.md)** — submission path.
  No direct `cardano-api` usage.

The current state of each page is **planning only** — nothing is
ported yet. See the [parity matrix](../dsl/parity-matrix.md) for
live status.
