# Contract: Shared Test Vector Store

**Feature**: [../spec.md](../spec.md) | **Plan**: [../plan.md](../plan.md)

The canonical test-vector store at `vectors/set-membership/` is the
single source of truth (constitutional principle 6a, FR-004, FR-005).
Every backend's test suite must consume it directly; no backend-local
fixtures for this primitive may exist.

## Directory layout

```text
vectors/set-membership/
├── schema.json            # JSON Schema 2020-12 document (both case types)
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

Adding a new vector is a single-file diff. Removing a vector requires
registering the corresponding parity-matrix cell as a gap.

## Shared conventions

- All byte strings are hex-encoded lowercase without `0x` prefix.
- All strings use Unicode; JSON is UTF-8 with no BOM.
- Every vector carries a `name` that is unique within its subdirectory
  and a `citation` field naming the paper / section that justifies the
  construction (principle 7a).

## JSON Schema (illustrative core)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://lambdasistemi.github.io/zk-lab/schemas/set-membership/v1.json",
  "oneOf": [
    { "$ref": "#/$defs/PositiveCase" },
    { "$ref": "#/$defs/TamperingCase" }
  ],
  "$defs": {
    "HexBytes": { "type": "string", "pattern": "^[0-9a-f]*$" },

    "PositiveCase": {
      "type": "object",
      "required": ["kind", "name", "set", "canonicalSet",
                   "canonicalTag", "value", "expectedVerdict",
                   "citation"],
      "properties": {
        "kind":          { "const": "positive" },
        "name":          { "type": "string" },
        "set":           {
          "type": "array", "items": { "$ref": "#/$defs/HexBytes" }
        },
        "canonicalSet":  {
          "type": "array", "items": { "$ref": "#/$defs/HexBytes" },
          "description": "Sorted and deduped; must be monotonic."
        },
        "canonicalTag": {
          "$ref": "#/$defs/HexBytes",
          "description": "SHA-256 of domain-separation tag ++ canonicalSet bytes."
        },
        "value":         { "$ref": "#/$defs/HexBytes" },
        "expectedVerdict": { "const": "accept" },
        "citation":      { "type": "string" }
      }
    },

    "TamperingCase": {
      "type": "object",
      "required": ["kind", "name", "baseCase", "mutation",
                   "expectedVerdict", "citation"],
      "properties": {
        "kind":          { "const": "tampering" },
        "name":          { "type": "string" },
        "baseCase":      {
          "type": "string",
          "description": "PositiveCase name this mutates."
        },
        "mutation":      { "$ref": "#/$defs/Mutation" },
        "expectedVerdict": { "const": "reject" },
        "citation":      { "type": "string" }
      }
    },

    "Mutation": {
      "oneOf": [
        {
          "type": "object",
          "required": ["tag", "value"],
          "properties": {
            "tag":   { "const": "non-member" },
            "value": { "$ref": "#/$defs/HexBytes" }
          }
        },
        {
          "type": "object",
          "required": ["tag", "otherSet"],
          "properties": {
            "tag":      { "const": "wrong-commitment" },
            "otherSet": {
              "type": "array", "items": { "$ref": "#/$defs/HexBytes" }
            }
          }
        },
        {
          "type": "object",
          "required": ["tag", "bitIndex"],
          "properties": {
            "tag":      { "const": "flipped-proof-bit" },
            "bitIndex": { "type": "integer", "minimum": 0 }
          }
        },
        {
          "type": "object",
          "required": ["tag", "otherSet"],
          "properties": {
            "tag":      { "const": "replay-across-sets" },
            "otherSet": {
              "type": "array", "items": { "$ref": "#/$defs/HexBytes" }
            }
          }
        }
      ]
    }
  }
}
```

## Example positive case

```json
{
  "kind": "positive",
  "name": "small-set",
  "set": [
    "616c696365",
    "626f62",
    "636861726c6965"
  ],
  "canonicalSet": [
    "616c696365",
    "626f62",
    "636861726c6965"
  ],
  "canonicalTag": "<sha256 of tag ++ concat(canonicalSet)>",
  "value": "626f62",
  "expectedVerdict": "accept",
  "citation": "Merkle 1987, DOI:10.1007/3-540-48184-2_32"
}
```

## Example tampering case

```json
{
  "kind": "tampering",
  "name": "non-member-bob-becomes-dave",
  "baseCase": "small-set",
  "mutation": {
    "tag": "non-member",
    "value": "64617665"
  },
  "expectedVerdict": "reject",
  "citation": "GMR 1989, §3 soundness, DOI:10.1137/0218012"
}
```

## CI validation

Two checks run in CI on this store:

1. **Schema validation**: every file under `positive/` or `tampering/`
   validates against `schema.json`. Any drift fails CI.
2. **Canonicalization check**: for every `PositiveCase`,
   `sort(dedup(set)) == canonicalSet` and
   `sha256(tag ++ concat(canonicalSet)) == canonicalTag`. This catches
   hand-edited vectors that drift from the canonicalization rule
   without involving any backend.

The two checks together make the vector store self-describing —
backend PRs can add cases confidently without re-reading this file.

## What is deliberately absent

- No field for the `Proof` bytes. Proofs are regenerated per-backend
  from `(set, value)` at test time; embedding a concrete proof would
  couple the store to one backend's format.
- No field for the `SetCommitment`. Same reason — each backend derives
  its own from `canonicalSet`.
- No `SetupParameters` / `CRS`. These are backend-internal.
