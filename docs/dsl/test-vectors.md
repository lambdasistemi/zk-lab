# Test vectors

One statement, one store, every backend.

## Why a shared store

Each backend is tempted to grow its own fixtures. Over time, those
fixtures drift. A bug that shows up on Groth16 stays hidden on BBS+
because the inputs were subtly different. Parity rots.

The lab solves this by locating the canonical inputs *outside* any
backend. There is exactly one place per statement where test
vectors live; every backend must pass them.

## Layout

```
vectors/
└── <statement>/
    ├── cases.json        # canonical inputs and expected verdicts
    ├── witness.json      # private and public witness values
    └── README.md         # provenance and any notes
```

## Format

`cases.json` is a list of named cases, each with:

```json
{
  "name": "accepts-valid-witness",
  "kind": "positive",
  "public": { "... public inputs ..." },
  "expected": "accept"
}
```

and negative cases:

```json
{
  "name": "rejects-tampered-public-input",
  "kind": "negative",
  "public": { "... tampered inputs ..." },
  "expected": "reject",
  "reason": "public input PI[0] flipped to 0"
}
```

The format is deliberately simple JSON so that Haskell, Rust,
Aiken (via off-chain compilation), and Lean can all read it.

## The parity rule

A backend claims ✅ for an intention *if and only if* it passes
**every** case in the statement's `cases.json` with the expected
verdict. Adding a new case that any backend fails is a
consistency bug — either the case or the backend is wrong.

## Where vectors come from

- **Copy-over from source repos.** The Groth16 voucher-spend
  vectors are ported from `harvest-015`; the BBS+ credential
  vectors from `cardano-bbs`. Provenance recorded in each
  `vectors/<statement>/README.md`.
- **New experiments.** A new intention lands with its own vectors
  in the same PR that lands its Lean property.
- **Community contributions.** Vectors can arrive from anywhere;
  attribution is required, cryptographic sanity checks
  (deserialization, type) run in CI before merging.
