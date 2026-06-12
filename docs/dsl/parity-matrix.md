# Parity matrix

The parity matrix is the lab's honesty mechanism. Every intention ×
every backend cell has one of three values:

| Value | Meaning |
|-------|---------|
| ✅ **works** | Implementation passes all shared test vectors and satisfies the Lean property. |
| ⚠️ **gap** | Not yet implemented, *and* there is no known reason it can't be. Tracked as a work item. |
| ❌ **incompatible** | Implementation is infeasible in this backend for a stated, documented reason (e.g. Plutus budget, cryptographic impossibility). Must link to the rationale. |

## Current state (bootstrap)

| Intention \ Backend                         | Groth16 | BBS+   | Halo2  |
|---------------------------------------------|---------|--------|--------|
| Selective disclosure                        | ⚠️ gap  | ⚠️ gap | ⚠️ gap |
| Voucher spend                               | ⚠️ gap  | ⚠️ gap | ⚠️ gap |
| Range                                       | ⚠️ gap  | ⚠️ gap | ⚠️ gap |
| [Set membership][set-membership-spec]       | [⚠️ gap][sm-groth16] | [⚠️ gap][sm-bbs] | [⚠️ gap][sm-halo2] |
| Threshold                                   | ⚠️ gap  | ⚠️ gap | ⚠️ gap |

[set-membership-spec]: https://github.com/lambdasistemi/zk-lab/blob/main/specs/001-set-membership/spec.md
[sm-groth16]: https://github.com/lambdasistemi/zk-lab/issues/10
[sm-bbs]: https://github.com/lambdasistemi/zk-lab/issues/11
[sm-halo2]: https://github.com/lambdasistemi/zk-lab/issues/12

Everything is a gap because nothing is ported yet. This is the
starting state; the [Groth16](../implementation/groth16.md) and
[BBS+](../implementation/bbs.md) backends come in from
`harvest-015` and `cardano-bbs` next.

## Enforcement

The matrix is review-enforced today: reviewers block a PR that

- adds an intention without populating a cell for every backend;
- moves a cell from ✅ to ⚠️ without a justification in the PR
  description;
- claims ✅ without passing the shared test vectors for the cell.

There is no CI job that parses this table yet. What *is* automated and
backs a green cell is the pair of gates a backend PR has to clear: the
shared-vector gates (`just check-vectors`) and the Lean ↔ QuickCheck
property-parity gate (`just check-property-parity`, CI app
`property-parity`). A ✅ that those gates do not support is a
parity-matrix bug.

## The escape hatch

A cell may be **❌ incompatible** if and only if the PR that sets it
includes:

- a link to the specific cryptographic or cost constraint that
  forbids implementation;
- a note in the relevant experiment README restating the
  limitation in plain language.

A red cell is a learning. A yellow cell is a task. A green cell is a
contract.
