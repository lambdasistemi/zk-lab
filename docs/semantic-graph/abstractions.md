# Abstractions

The mathematics that make the promises keep. This chapter filters
the graph to the formal layer: properties, arithmetizations,
commitments, setups, and the protocols that compose them.

!!! info "Embed status"
    The embedded graph below loads the full `zk-lab` graph; pick
    *Abstractions* from the view/filter picker once inside.
    Per-chapter URL filtering is tracked upstream as
    [graph-browser#68](https://github.com/lambdasistemi/graph-browser/issues/68).

<iframe
  title="zk-lab semantic graph — abstractions view"
  src="https://lambdasistemi.github.io/graph-browser/?repo=lambdasistemi/zk-lab&view=abstractions"
  width="100%" height="600" loading="lazy"
  style="border: 1px solid #444; border-radius: 6px;">
</iframe>

## The three properties

Completeness, soundness, zero-knowledge — each with its own classical
tension:

- **Completeness vs soundness.** Easy to get one; the game is in
  getting both.
- **Soundness vs knowledge-soundness.** A sound proof says
  "statement is true"; a knowledge-sound proof says "prover
  *knew* why." The upgrade from the first to the second is
  formalized via an **extractor** — a hypothetical algorithm
  producing the witness from a convincing prover's transcript.
- **Zero-knowledge strength.** Perfect (simulator is exact) /
  statistical (indistinguishable except by negligible probability) /
  computational (indistinguishable to bounded adversaries). Most
  deployed systems are the last.

## Arithmetization: how statements become algebra

A proof system does not see "a voucher spend." It sees a polynomial
identity over a finite field that must hold if and only if the
statement is true. Getting from one to the other is
*arithmetization*:

- **R1CS** — the classical target. Three vectors per constraint.
  Circom compiles to R1CS. Groth16 consumes it.
- **PLONKish** — tables, custom gates, lookups. More expressive,
  less rigid. Halo2 is PLONKish.

The trade-off: R1CS is more restrictive, which makes the prover and
verifier simpler. PLONKish is looser, which lets the circuit author
express more, at the cost of heavier verification.

## Commitments and setups

Commitments let a prover bind to a value before revealing anything
about it — the building block of every non-trivial ZK system.

- **Pedersen** — no trusted setup; perfectly hiding. The non-pairing
  heart of BBS+ and many Sigma-protocol constructions.
- **KZG** — pairing-based polynomial commitment; requires a trusted
  (powers-of-tau) setup. The engine of PLONK, Halo2, and Groth16's
  verification.

The setup model — trusted per circuit, trusted universal, or
transparent — is the single knob that shapes how a system is
deployed, how ceremonies are run (or not), and how quantum-robust
it is.

## Fiat–Shamir

The hinge between interactive and non-interactive: replace the
verifier's random challenges with the hash of the transcript so far
[^FS]. Soundness becomes dependent on the hash being "like a random
oracle." Every non-interactive SNARK used in production rests on
this substitution.

## Sources

[^FS]: Fiat, A.; Shamir, A. (1986). **How to prove yourself:
Practical solutions to identification and signature problems**.
CRYPTO '86.
<https://link.springer.com/chapter/10.1007/3-540-47721-7_12>.

- Boneh, D.; Shoup, V. **A Graduate Course in Applied Cryptography**.
  <https://toc.cryptobook.us/>. *A standard free reference used
  throughout this chapter.*
- Thaler, J. **Proofs, Arguments, and Zero-Knowledge**.
  <https://people.cs.georgetown.edu/jthaler/ProofsArgsAndZK.pdf>.
  *Primary teaching text for the abstractions covered here.*
