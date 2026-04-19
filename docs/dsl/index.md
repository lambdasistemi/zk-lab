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

None of this is implemented yet. This PR is the documentation
scaffold. Implementation lands in subsequent PRs, one primitive at a
time, each requiring: a Lean property, a QuickCheck generator, a
test-vector file, and parity across all supported backends (or an
explicit gap entry).
