# DSL

The DSL is the product. Everything else is plumbing.

A DSL user writes **intentions** — statements of the form "I want to
prove X" — and the lab figures out how to realize them on a chosen
backend. The user never touches R1CS, custom gates, or BBS+
generator derivation.

## The contract

- **[Intentions](intentions.md)** — the vocabulary of statements
  the DSL understands.
- **[Backends as plumbing](backends.md)** — how intentions map to
  Groth16, BBS+, Halo2. What the uniform backend interface looks
  like.
- **[Parity matrix](parity-matrix.md)** — intention × backend →
  {works, gap, incompatible}. Gaps are bugs.
- **[Test vectors](test-vectors.md)** — the single store of
  canonical inputs every backend must pass.
- **[Properties (Lean + QC)](properties.md)** — every primitive
  specified twice: formally in Lean, executably in QuickCheck.

## Status

The first primitive — [set membership](primitives/set-membership.md) —
has landed as a DSL-only slice. What exists today:

- the DSL surface (`ZK.DSL.SetMembership`, `ZK.DSL.Intention`) and the
  backend-independent canonicalizer (`ZK.Canonicalize`);
- the dual property specification — Lean theorems in
  `lean/ZKLab/SetMembership.lean` and their QuickCheck counterparts in
  `ZK.DSL.Properties.SetMembership`, kept 1:1 by a CI parity gate;
- the shared [test-vector store](test-vectors.md) under
  `vectors/set-membership/`;
- an Aiken verifier skeleton under `onchain/verifiers/set_membership/`.

What does not exist yet: any backend. No Groth16, BBS+, or Halo2
instance has landed, so every cell in the [parity
matrix](parity-matrix.md) is still a gap. Subsequent PRs add backends
one at a time, each requiring vectors to pass and the Lean/QuickCheck
properties to hold (or an explicit gap entry).
