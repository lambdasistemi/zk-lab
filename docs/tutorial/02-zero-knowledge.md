# 2. Zero-knowledge in one page

## The informal claim

A zero-knowledge protocol lets a **prover** convince a **verifier**
that a statement is true, such that:

- if the statement is true and both play honestly → the verifier is
  convinced (**completeness**);
- if the statement is false → no prover can convince the verifier,
  except with vanishing probability (**soundness**);
- the verifier learns **nothing beyond the truth of the statement**
  itself (**zero-knowledge**).

The third property is the startling one. It is made formal by the
existence of a **simulator** — an algorithm that, given only the
statement (not the witness), can produce a transcript that is
computationally indistinguishable from a real prover-verifier
interaction. If such a simulator exists, the verifier cannot have
learned anything the simulator couldn't have generated alone. Hence:
nothing.

This trick — proving absence of learning via the existence of a
faking algorithm — is due to Goldwasser, Micali, and Rackoff (1985)
[^GMR85]. It is where the field begins.

## Why the three properties are all non-trivial

- **Completeness without soundness** is a receipt: trivially
  convinces, protects nothing.
- **Soundness without zero-knowledge** is a classical proof: a
  signed attestation, a digital signature over the statement and
  its evidence.
- **Zero-knowledge without soundness** is a magic trick: nothing is
  revealed *and* nothing is verified.

All three together — completeness, soundness, zero-knowledge — are
what make the protocols interesting and what make them hard.

## The three flavors that matter for this lab

| Flavor | What is fixed in advance | On-chain story |
|--------|--------------------------|----------------|
| **Groth16** [^Groth16] | The statement (as a circuit). A trusted setup is run *per circuit*. | Fast, tiny proofs (~200 bytes). Plutus has native BN254 pairings. |
| **BBS+** [^BBS23] | The signer's key. No per-statement setup. | Selective disclosure over credentials. Plutus has native BLS12-381 pairings. |
| **Halo2 / PLONKish** [^PLONK][^Halo2] | Nothing per-statement. Universal setup (KZG or transparent). | No per-circuit ceremony, but Plutus verifier is an open question: KZG openings at scale are expensive. |

These are three points in a larger design space. The lab's DSL
exists precisely because, for a given statement, the "best" backend
is not obvious and is not the same across statements.

## What a proof does *not* prove

Even a perfect zero-knowledge proof only proves what the statement
says. Two common mistakes:

1. **The statement is too weak.** "I know *some* witness to
   relation R" may be sound, but if R was written incorrectly, the
   witness may not correspond to anything meaningful.
2. **The proof is isolated from the world.** A proof that "I own
   this credential" does not, by itself, prevent replay, nor bind
   the proof to a transaction. Binding proofs to context (nullifiers,
   nonces, transaction data) is a separate design problem.

The DSL's job is to make the first mistake hard — by hoisting
statements to a level where the semantics are clear — and to make
the second mistake visible, by giving statements explicit context.

---

## Sources cited on this page

[^GMR85]: Goldwasser, S.; Micali, S.; Rackoff, C. (1985). **The
knowledge complexity of interactive proof-systems**. *STOC '85*.
[DOI:10.1145/22145.22178](https://doi.org/10.1145/22145.22178).
*Originating paper; the simulator-based definition used above is from
here.*

[^Groth16]: Groth, J. (2016). **On the Size of Pairing-Based
Non-interactive Arguments**. *EUROCRYPT 2016*. [IACR
ePrint 2016/260](https://eprint.iacr.org/2016/260).
*The scheme itself.*

[^BBS23]: Looker, T.; Kalos, V.; Whitehead, A.; Lodder, M. (2023+).
**The BBS Signature Scheme**. IRTF CFRG draft.
[draft-irtf-cfrg-bbs-signatures](https://datatracker.ietf.org/doc/draft-irtf-cfrg-bbs-signatures/).
*Working specification the lab's BBS+ backend follows.*

[^PLONK]: Gabizon, A.; Williamson, Z. J.; Ciobotaru, O. (2019).
**PLONK: Permutations over Lagrange-bases for Oecumenical Noninteractive
arguments of Knowledge**. [IACR ePrint
2019/953](https://eprint.iacr.org/2019/953). *The arithmetization Halo2 builds on.*

[^Halo2]: Zcash Foundation / Privacy & Scaling Explorations.
**The Halo2 Book**. <https://zcash.github.io/halo2/>. *Primary
reference for the Halo2 backend.*

---

**Next:** [Groth16 intuition](03-groth16.md) — what the pairing-based
workhorse actually does.
