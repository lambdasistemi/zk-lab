# Properties (Lean + QuickCheck)

Every DSL primitive is specified **twice**:

- in **Lean** — formally, machine-checked, as the single source of
  truth for what the primitive means;
- in **QuickCheck** — executably, as the harness every backend runs
  its implementation against.

The two specifications must agree. When they disagree, the Lean
statement wins and the QuickCheck property is brought into line.

## Why two

- **Lean guards meaning.** A property written only as QC can drift:
  generators miss edge cases, properties get weakened to pass
  flaky tests. Lean cannot silently drift — a theorem either has a
  proof or it doesn't.
- **QC guards implementation.** A theorem is about an idealization;
  a backend is code. QuickCheck tests — on shared test vectors and
  on random inputs — are how we detect when the code deviates from
  what the theorem covers.

This dual specification is explicitly in the
[constitution](../constitution.md) (principle 6b) and enforced by
CI.

## Layout

One Lean module and one QuickCheck module per primitive. Today only
the set-membership pair exists:

```text
lean/
├── ZKLab.lean                  -- top-level import
└── ZKLab/
    └── SetMembership.lean       -- P1–P6 as `theorem`s (bodies `sorry`)

offchain/src/ZK/DSL/Properties/
└── SetMembership.hs             -- genSet + the prop_* counterparts
```

Each future primitive adds a `lean/ZKLab/<Primitive>.lean` plus a
`offchain/src/ZK/DSL/Properties/<Primitive>.hs`. The two must stay in
1:1 correspondence: `offchain/scripts/check-property-parity.sh` (CI app
`property-parity`) fails the build if a `theorem` in the Lean parity
section has no matching `prop_*`, or vice versa (SC-003). For set
membership the mapping is pinned in
[`contracts/properties.md`][contract].

[contract]: https://github.com/lambdasistemi/zk-lab/blob/main/specs/001-set-membership/contracts/properties.md

## Shape of a property

For each intention, both specs state at least:

1. **Completeness.** Honest prover + true witness → verify accepts.
2. **Soundness.** Any witness that makes the verifier accept satisfies
   the DSL-level relation. (Often stated as: *if verify = true and
   the witness is in the domain, the relation holds.*)
3. **Zero-knowledge.** Not directly checkable in QuickCheck; stated
   as a Lean obligation referencing the backend's simulator.
4. **Parity.** The Haskell DSL's interpretation of the statement
   matches the Lean idealization.

## Where backends fit in

Backends do not prove the properties. They consume the shared
[test vectors](test-vectors.md) and must pass every case. If a case
passes Lean and QuickCheck but fails on a backend, the backend has
a bug. If a case fails in Lean, the property is wrong.
