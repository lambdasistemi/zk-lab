# Halo2 backend

!!! warning "Status"
    Not started. Plutus verifier feasibility is the first open
    research question — not a porting exercise like Groth16/BBS+.

## Plan

- Rust FFI crate: `offchain/cbits/halo2-ffi/` wrapping the PSE
  [`halo2`](https://github.com/privacy-scaling-explorations/halo2)
  fork.
- Haskell modules: `offchain/src/ZK/Halo2/*`, same shape as
  Groth16 and BBS+.
- Aiken verifier: **open**. KZG opening verification at nontrivial
  circuit sizes may exceed Plutus's per-script budget. The first
  task is to characterize the budget and decide whether to scope
  in a Halo2 verifier at all.

## Why start with the Plutus question

Porting the prover is effort we already know how to spend. The
unknown is whether anything we prove can actually be verified on
chain. Spending months on a full port before answering that
question would be premature. The first Halo2 PR is a feasibility
spike: a minimal circuit, a minimal verifier, measured against
Plutus V3 budgets.

## If the Plutus verifier is infeasible

The matrix cell is marked ❌ **incompatible** with a link to the
measurement. Halo2 stays in the lab — off-chain, for recursion and
prover experimentation — but the DSL does not promise Plutus
verification for Halo2-backed statements. This is an honest gap, not
a failure.
