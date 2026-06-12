# Set membership

The first DSL primitive to land. A prover claims "this private value
belongs to this set" and produces an [`Intention
'SetMembership`](../intentions.md). No backend is named in the DSL
author's code; the same intention expression is compiled by every
parity-complete backend.

This page walks the primitive from user-facing intention down to the
canonicalization rules that every backend must agree on. Nothing
cryptographic lives here — that lives in the
[backends](../../implementation/index.md).

## Intention

The public surface, matching
[`contracts/intention.md`][contracts-intention] exactly:

```haskell
import ZK.Backend.Tag (BackendTag (Groth16))
import ZK.DSL.Intention (Intention, StatementFamily (SetMembership))
import ZK.DSL.SetMembership
    ( Element (..)
    , SetCommitment
    , Value (..)
    , fromList
    , member
    )

-- `fromList` is the only way to build a Set: it returns Nothing on
-- the empty list and canonicalises (lex-sort + dedup) otherwise.
claim :: Maybe (Intention 'SetMembership)
claim = do
    theSet <-
        fromList
            [ Element "alice"
            , Element "bob"
            , Element "charlie"
            ]
    let commit :: SetCommitment 'Groth16
        commit = commitSet theSet -- commitSet comes from the backend
    pure (Value (Element "alice") `member` commit)
```

`commitSet` is deliberately not imported here — it comes from
whichever backend module the caller wires up. The `member` call is
backend-polymorphic (`SetCommitment s -> Intention 'SetMembership`);
the only place a backend name surfaces is the phantom tag on
`SetCommitment` (here `'Groth16`, from `ZK.Backend.Tag`).

## Semantics

The two statements the primitive makes precise:

- __P4 — canonicalization is idempotent.__ `fromList . toList .
  fromList ≡ fromList`. Dedup + lex sort is the canonical form, so
  semantically equal sets produce identical commitments regardless of
  the input order or duplicates.
- __P5 — empty sets are rejected.__ `fromList [] ≡ Nothing`. An empty
  set carries no membership statement; the DSL rejects it at
  construction time.

Both are specified twice: as QuickCheck properties
(`prop_canonicalization_idempotent`, `prop_empty_rejected`) in
`ZK.DSL.Properties.SetMembership`, and as Lean theorems
(`canonicalization`, `emptyRejected`) in
`lean/ZKLab/SetMembership.lean`. The full mapping of DSL property ↔
Lean theorem ↔ QuickCheck property — all six, P1–P6 — lives in
[contracts/properties.md][contracts-properties].

## Canonicalization

Decision [D-05][research-d05] of research.md pins the canonical form:

1. __Lex-sort__ elements by their underlying bytes.
2. __Dedup__ — duplicate bytes collapse to one element.
3. __Concatenate__ the ordered, deduplicated bytes. No length prefix,
   no separator.
4. __SHA-256__ of `"zk-lab/set-membership/v1" ++ concat` gives the
   32-byte canonicalization tag that ships alongside every positive
   test vector.

The tag is __not__ a cryptographic commitment — each backend picks its
own. It exists so vectors can cross-check every backend reached the
same canonical form before applying its own commitment scheme, turning
canonicalization drift into a test failure instead of a silent
soundness bug.

Implemented in `ZK.Canonicalize`:

```haskell
canonicalSetBytes :: Set -> ByteString
canonicalTag      :: Set -> ByteString  -- 32 bytes, SHA-256
```

## Implementation status

Every cell is currently ⚠️ gap in the
[parity matrix](../parity-matrix.md): the DSL surface exists, but no
backend has landed its `Backend 'Groth16`, `Backend 'BBSPlus`, or
`Backend 'Halo2` instance yet. Concretely:

- The [Groth16 backend](../../implementation/groth16.md) arrives from
  `harvest-015`.
- The [BBS+ backend](../../implementation/bbs.md) arrives from
  `cardano-bbs`.
- The [Halo2 backend](../../implementation/halo2.md) has no known port
  yet; it is on the roadmap.

Until those land, `commitSet`, `prove`, and `verifyOff` are not
callable — the DSL types compile against them, but no instance
exists. That is the point of the parity matrix: the gap is visible,
not papered over.

## Where to look next

- [Intentions overview](../intentions.md) — how a statement is shaped.
- [Properties (Lean + QC)](../properties.md) — how P1–P6 are
  formalized and checked.
- [Parity matrix](../parity-matrix.md) — the honesty ledger.
- [Test vectors](../test-vectors.md) — the shared JSON store each
  backend consumes.
- [Citations](../citations.md) — Merkle 1987, GMR 1989, D-05.

[contracts-intention]: https://github.com/lambdasistemi/zk-lab/blob/main/specs/001-set-membership/contracts/intention.md
[contracts-properties]: https://github.com/lambdasistemi/zk-lab/blob/main/specs/001-set-membership/contracts/properties.md
[research-d05]: https://github.com/lambdasistemi/zk-lab/blob/main/specs/001-set-membership/research.md#d-05-canonicalization-lexicographic-sort--dedup-sha-256-tagged
