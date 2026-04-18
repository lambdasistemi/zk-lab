# 1. Why zero-knowledge?

## The ordinary situation

Most of the time, when you convince someone of something, you hand
over evidence. You show your ID. You send the document. You forward
the email. The evidence *is* the fact; inspecting it is how the other
party is convinced.

This works until the evidence is also something you'd rather not
share. Your salary. Your medical history. Your exact location. The
identities of your coalition partners. The contents of a sealed bid.
The amount in your wallet. The fact that you are 18, without
revealing your birthday. The fact that a vote was cast, without
revealing who cast it.

In those situations, ordinary evidence is the wrong tool. Handing it
over proves the claim *and* discloses everything adjacent to the
claim. The collateral damage is the product.

## The change of stance

Zero-knowledge flips the stance. Instead of "here is the evidence,
judge for yourself," the prover says:

> "I can demonstrate — by running a protocol with you — that the
> claim is true. At the end of the protocol, you will be as
> convinced as if you had seen the evidence. You will not have seen
> any more of the evidence than was strictly needed for the
> demonstration, which is: none of it."

The word "demonstration" is doing a lot of work. It's not rhetoric.
It is a specific mathematical game whose outcome — if played
correctly — leaves the verifier convinced and the prover's private
data untouched.

## Three properties, one promise

Every zero-knowledge protocol must satisfy three properties at once:

- **Completeness** — if the claim is true and both parties play
  honestly, the verifier is convinced.
- **Soundness** — if the claim is false, no prover (even a cheating
  one) can convince the verifier except with negligible probability.
- **Zero-knowledge** — whatever the verifier learns from the
  protocol, they could have simulated on their own without the
  prover. So they learn nothing beyond the claim.

Completeness and soundness are properties any decent proof system
has. Zero-knowledge is the one that matters for privacy. It is
formally defined using a *simulator*: a hypothetical algorithm that
produces the verifier's entire transcript without ever talking to
the real prover. If such a simulator exists, the protocol leaks
nothing.

## Why Cardano, why now

The lab is on Cardano for three reasons.

- **Plutus is a restricted enough VM** that the cost of verifying a
  proof on chain is visible and tight. This makes honest engineering
  possible: there is nowhere to hide a slow verifier.
- **Cardano has native pairing primitives** for BN254 and BLS12-381
  at the script layer. Groth16 and BBS+ are buildable *today*. Halo2
  is an open research question — which is why it's interesting.
- **The cultural moment is right.** Regulation is pushing toward
  identity systems that either collapse privacy or carve out real
  space for zero-knowledge. A public laboratory that does the second
  honestly is a useful thing to have.

## Why a DSL

Because writing the same statement three times — once for Groth16,
once for BBS+, once for Halo2 — is both wasteful and dangerous. The
three expressions will subtly diverge. The parity story rots.

The DSL is where the *statement* lives, once. The backends are where
the *realization* lives. When you write a new primitive, the
constitution forces you to either implement it everywhere or
register the gap. That is how the parity matrix stays honest.

## Why this lab

Because none of the above is obvious until you've tried it. The
lab's purpose is to try it — carefully, reproducibly, with the
negative results written down — so that the next project built on
top of it doesn't have to.

---

**Next:** [Zero-knowledge in one page](02-zero-knowledge.md) — the
property itself, without the math.
