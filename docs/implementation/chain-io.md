# cardano-node-clients

Chain I/O — tx construction, submission, query — goes through the
[`cardano-node-clients`](https://github.com/cardano-scaling/cardano-node-clients)
library. **No direct `cardano-api` imports.** No bridge conversion
functions between legacy types and new types.

## Why

- `cardano-node-clients` is the supported path for off-chain tooling
  in the scope the lab targets: preprod-style testing, local cluster
  integration, programmable tx flows.
- Direct `cardano-api` use creates a second type system that leaks
  into the DSL and produces a forest of converters. Constitution
  principle: no bridges.

## What belongs here

- Minting and spending scripts that carry DSL proofs.
- Query helpers for per-statement state (e.g. nullifier sets, issuer
  registries) when the statement's validator needs them.
- Test harnesses that submit real txs on a local/preprod cluster and
  assert the on-chain verifier's verdict.

## What does not belong here

- Tx building for experiments that have no DSL statement. Prose
  experiments belong in the semantic graph; code experiments need a
  statement.
- Any code that replicates functionality already exported by
  `cardano-node-clients`. If an abstraction is missing upstream, the
  lab files an issue there, not a workaround here.
