# Parity matrix

The parity matrix is the lab's honesty mechanism. Every intention ×
every backend cell has one of three values:

| Value | Meaning |
|-------|---------|
| ✅ **works** | Implementation passes all shared test vectors and satisfies the Lean property. |
| ⚠️ **gap** | Not yet implemented, *and* there is no known reason it can't be. Tracked as a work item. |
| ❌ **incompatible** | Implementation is infeasible in this backend for a stated, documented reason (e.g. Plutus budget, cryptographic impossibility). Must link to the rationale. |

## Current state (bootstrap)

| Intention \ Backend | Groth16 | BBS+ | Halo2 |
|---------------------|---------|------|-------|
| Selective disclosure | ⚠️ gap | ⚠️ gap | ⚠️ gap |
| Voucher spend       | ⚠️ gap | ⚠️ gap | ⚠️ gap |
| Range               | ⚠️ gap | ⚠️ gap | ⚠️ gap |
| Set membership      | ⚠️ gap | ⚠️ gap | ⚠️ gap |
| Threshold           | ⚠️ gap | ⚠️ gap | ⚠️ gap |

Everything is a gap because nothing is ported yet. This is the
starting state; the [Groth16](../implementation/groth16.md) and
[BBS+](../implementation/bbs.md) backends come in from
`harvest-015` and `cardano-bbs` next.

## Enforcement

CI reads this page (or a structured sidecar) and fails PRs that:

- add an intention without populating a cell for every backend;
- move a cell from ✅ to ⚠️ without an accompanying justification
  in the PR description;
- claim ✅ without passing the shared test vectors for the cell.

## The escape hatch

A cell may be **❌ incompatible** if and only if the PR that sets it
includes:

- a link to the specific cryptographic or cost constraint that
  forbids implementation;
- a note in the relevant experiment README restating the
  limitation in plain language.

A red cell is a learning. A yellow cell is a task. A green cell is a
contract.
