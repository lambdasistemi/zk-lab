# zk-lab

Laboratory for zero-knowledge and privacy-preserving signature primitives on Cardano.

The goal: express statements once in a high-level intention-driven DSL and compile
them to Plutus-verifiable proofs across multiple backends — Groth16 (arkworks),
BBS+ (zkryptium), and eventually Halo2 (PSE) — with feature parity as a design target.

## Status: experimental, toy trusted setups only

This is an experimentation repo, not a production library. In particular:

- No backend in this repo has undergone an independent trusted-setup ceremony.
  The fixtures and bundled setups are for learning and parity testing only.
- Shared test vectors and Lean property proofs are the correctness contract;
  cryptographic soundness at production scale is out of scope (FR-011).
- Do not use any artifact from this repo on mainnet or for anything
  security-sensitive.

The first primitive to land end-to-end is
[set membership](https://lambdasistemi.github.io/zk-lab/dsl/primitives/set-membership/).
It ships as a DSL-only slice: no backend, six dual-specified properties
(Lean + QuickCheck), and a shared test-vector store. Backend ports arrive
in follow-up PRs.

## Documentation

See [the MkDocs site](https://lambdasistemi.github.io/zk-lab/) for the constitution,
[parity matrix](https://lambdasistemi.github.io/zk-lab/dsl/parity-matrix/),
[set membership primitive](https://lambdasistemi.github.io/zk-lab/dsl/primitives/set-membership/),
and experiment write-ups.

## License

Apache-2.0
