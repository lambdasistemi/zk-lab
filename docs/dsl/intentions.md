# Intentions

An **intention** is a user-visible statement shape. It answers the
question *"what is being proved?"* at a level of abstraction where
the answer is intelligible without knowing which backend will
eventually realize it.

## Initial vocabulary

The first intentions the lab targets, ordered roughly by how
tractable they are across backends:

| Intention | Meaning | Natural backend(s) |
|-----------|---------|--------------------|
| **Selective disclosure** | "I hold a credential signed by known issuer *I* over attributes *a*; attributes at positions *P* equal specific public values." | BBS+ |
| **Voucher spend** | "I know a preimage *w* such that *H(w)* is a leaf of a Merkle tree with root *r*, and I commit to a nullifier derived from *w* bound to transaction context *t*." | Groth16 |
| **Range** | "The hidden value *x* lies in interval [*a*, *b*]." | BBS+ (natively), Groth16 (via circuit), Halo2 |
| **Set membership** | "*x* ∈ *S*, where *S* is committed by root *r*." | Groth16, Halo2 |
| **Threshold** | "*k* of *n* credentials cosigned this statement." | BBS+ (with extensions), Halo2 |

This list expands with experiments. Every addition requires:

1. A *why* (see the [semantic graph /
   challenges](../semantic-graph/challenges.md) for real-world
   drivers).
2. A Lean property pinning the meaning.
3. A QuickCheck generator for execution.
4. A test-vector file (shared across backends).
5. A parity commitment (or an explicit gap entry).

## What intentions are *not*

- Not circuits. A circuit is a realization, not a statement.
- Not protocols. An intention is a statement; ritual around the
  statement (issuance, revocation, binding to context) is protocol
  work.
- Not performance claims. "Fast voucher spend" is not an intention.
  "Voucher spend" is; performance is measured in benchmarks.
