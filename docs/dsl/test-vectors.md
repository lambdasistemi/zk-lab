# Test vectors

One statement, one store, every backend.

## Why a shared store

Each backend is tempted to grow its own fixtures. Over time, those
fixtures drift. A bug that shows up on Groth16 stays hidden on BBS+
because the inputs were subtly different. Parity rots.

The lab solves this by locating the canonical inputs *outside* any
backend. There is exactly one place per statement where test
vectors live; every backend must pass them. No backend-local fixtures
for a primitive are allowed (FR-005, constitutional principle 6a).

## Layout

The store that exists today is the set-membership store:

```text
vectors/set-membership/
├── schema.json            # JSON Schema 2020-12, both case types
├── positive/
│   ├── singleton.json
│   ├── small-set.json
│   └── canonical-dedup.json
└── tampering/
    ├── non-member.json
    ├── wrong-commitment.json
    ├── flipped-proof-bit.json
    └── replay-across-sets.json
```

Each future primitive lands its own `vectors/<statement>/` store in
the same shape. The full schema is pinned in
[`specs/001-set-membership/contracts/vectors.md`][contract].

## Format

Every file is a single JSON object — one case per file — that
validates against `schema.json`. There are two case kinds, told apart
by the `kind` discriminator.

**Positive case** (`kind: "positive"`, `expectedVerdict: "accept"`):

```json
{
  "kind": "positive",
  "name": "small-set",
  "set": ["616c696365", "626f62", "636861726c6965"],
  "canonicalSet": ["616c696365", "626f62", "636861726c6965"],
  "canonicalTag": "8173a1d612cfa0709264d7d47040c72cfd268da179c1b5508c062bd55c793a69",
  "value": "626f62",
  "expectedVerdict": "accept",
  "citation": "Merkle 1987, §2 (Authentication trees), DOI:10.1007/3-540-48184-2_32"
}
```

- All byte strings are lowercase hex, no `0x` prefix.
- `canonicalSet` is `set` after lex-sort + dedup.
- `canonicalTag` is the 32-byte (64 hex char) SHA-256 of
  `"zk-lab/set-membership/v1"` concatenated with the canonical bytes —
  see [set membership](primitives/set-membership.md#canonicalization).
  It is a canonicalization cross-check, **not** a cryptographic
  commitment.
- No `Proof` and no `SetCommitment` field: those are backend-specific
  and regenerated per-backend at test time.

**Tampering case** (`kind: "tampering"`, `expectedVerdict: "reject"`)
references a positive case by name and applies one of four mutations:

```json
{
  "kind": "tampering",
  "name": "non-member-dave",
  "baseCase": "small-set",
  "mutation": { "tag": "non-member", "value": "64617665" },
  "expectedVerdict": "reject",
  "citation": "GMR 1989, §3 (Soundness), DOI:10.1137/0218012"
}
```

The four mutation tags are: `non-member` (replace `value` with a
non-member), `wrong-commitment` (substitute a different `otherSet`),
`flipped-proof-bit` (flip the proof bit at `bitIndex`), and
`replay-across-sets` (replay the proof against a different `otherSet`).

## How the store is consumed and checked

- **Loader.** `ZK.Vectors.SetMembership` decodes the store into typed
  Haskell values (`PositiveCase`, `TamperingCase`, `Mutation`). Every
  backend's test suite reads through it — no re-parsing per backend.
- **Schema gate.** `just check-vectors` (nix app `vectors`, backed by
  `check-jsonschema`) validates every `positive/*.json` and
  `tampering/*.json` against `schema.json`.
- **Canonicalization gate.** `ZK.Vectors.SetMembershipSpec` (run by
  `just test-dsl`) recomputes `canonicalSet` and `canonicalTag` from
  each positive case's raw `set` with `ZK.Canonicalize` and fails on
  drift. Together the two gates make the store self-describing.

## The parity rule

A backend claims ✅ for an intention *if and only if* it passes
**every** case in the store with the expected verdict — every positive
case verifies, every tampering case rejects. Adding a case that any
parity-complete backend fails is a consistency bug — either the case
or the backend is wrong.

## Where vectors come from

- **New experiments.** A new intention lands with its own vectors in
  the same PR that lands its Lean property and QuickCheck module.
- **Community contributions.** Vectors can arrive from anywhere;
  attribution is required via the `citation` field, and the schema +
  canonicalization gates run in CI before merging.

[contract]: https://github.com/lambdasistemi/zk-lab/blob/main/specs/001-set-membership/contracts/vectors.md
