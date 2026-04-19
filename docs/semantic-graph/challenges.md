# Real-life challenges

Papers end where deployments begin. This chapter filters the graph
to the messy layer: governance, regulation, hardware, user
experience, and the quiet pile of silent failure modes that make ZK
engineering humbling.

!!! info "Embed status"
    The embedded graph below loads the full `zk-lab` graph; pick
    *Challenges* from the view/filter picker once inside.
    Per-chapter URL filtering is tracked upstream as
    [graph-browser#68](https://github.com/lambdasistemi/graph-browser/issues/68).

<iframe
  title="zk-lab semantic graph — challenges view"
  src="https://lambdasistemi.github.io/graph-browser/?repo=lambdasistemi/zk-lab&view=challenges"
  width="100%" height="600" loading="lazy"
  style="border: 1px solid #444; border-radius: 6px;">
</iframe>

## Governance of ceremonies

Running a trusted setup is a *governance* event. Who participates
decides whose trust assumption you are ratifying. The original Zcash
ceremony [^Zcash-ceremony] was a six-person radio-silent ritual; the
Ethereum KZG ceremony [^ETH-ceremony] deliberately inverted that by
inviting any participant at all. Between those two poles sits a
question the field has not settled: *how few honest participants are
few enough, and how do you convince a skeptical public that at least
one of them was honest?*

## Regulation

The regulatory landscape is changing under the field's feet.

- **eIDAS 2.0** [^eIDAS2] and the EU Digital Identity Wallet mandate
  selective disclosure for identity attributes — a BBS+-shaped hole
  in European law.
- **GDPR** [^GDPR] treats minimization as a legal principle. ZK is
  one of the few technical tools that implements it.
- **MiCA** [^MiCA] and the FATF Travel Rule [^Travel] push the other
  way: *more* traceability for crypto-assets. The collision between
  privacy-by-design and compliance-by-design is not a theoretical
  debate; it is an active policy fight.

The lab does not take a side, but it does record the forces.

## Auditability vs privacy

If a coalition cannot be audited, is it trustworthy? If it can be
fully audited, is it private? The usual answers — *viewing keys,
escrowed decryption, threshold disclosure, zero-knowledge
compliance proofs* — are all engineering answers to what is
ultimately a political question. The field has no consensus yet;
the proposals are mostly younger than five years.

## Silent failure: under-constrained circuits

A ZK circuit that forgets a constraint is not a *broken* circuit. It
is a *permissive* circuit: it accepts witnesses it should reject.
The verifier cannot tell. The prover may not notice. Production ZK
has had real, paid incidents here [^ZKBugs] [^TornadoBug].

Defenses:

- Formal verification (Lean [^Lean], Picus [^Picus], Ecne [^Ecne]).
- Dual-implementation: the same statement on a second backend; any
  behavioral divergence is a bug.
- Shared test vectors with negative cases.

The lab's constitution enforces the last two.

## Prover hardware

The prover is expensive. For nontrivial circuits, a laptop measures
provers in minutes; a server in seconds; specialized GPU and FPGA
rigs [^ProverHW] in hundreds of milliseconds. Whoever holds the
hardware holds the ability to prove at scale. That concentration is
a deployment risk, not just a performance footnote.

## User experience

The last mile. Wallet UX, key management, credential issuance,
credential storage, credential revocation, credential expiry. Each
has its own failure modes that have nothing to do with cryptography
and everything to do with product. The tutorial, and every
experiment in this repo, tries to keep sight of the UX mile.

## Sources

[^Zcash-ceremony]: Wilcox, Z. et al. **MPC+Ceremonies for Zcash
Sprout**. <https://electriccoin.co/blog/the-design-of-the-ceremony/>.

[^ETH-ceremony]: Ethereum Foundation. **KZG Ceremony**.
<https://ceremony.ethereum.org/>.

[^eIDAS2]: European Commission. **Regulation on European Digital
Identity (eIDAS 2.0)**.
<https://digital-strategy.ec.europa.eu/en/policies/eidas-regulation>.

[^GDPR]: European Parliament. **General Data Protection Regulation**.
<https://eur-lex.europa.eu/eli/reg/2016/679/oj>.

[^MiCA]: European Parliament. **Regulation on Markets in Crypto-Assets**.
<https://eur-lex.europa.eu/eli/reg/2023/1114/oj>.

[^Travel]: FATF. **Updated Guidance for a Risk-Based Approach to
Virtual Assets and VASPs**.
<https://www.fatf-gafi.org/en/publications/Fatfrecommendations/Updated-Guidance-RBA-VASP.html>.

[^ZKBugs]: ZKSecurity. **Awesome ZK Bugs**.
<https://github.com/0xPARC/zk-bug-tracker>.

[^TornadoBug]: Chainlight, Hayden Adams et al. **Write-ups of ZK
bugs discovered in production**. *See the ZK Bug Tracker above.*

[^Lean]: The Lean theorem prover. <https://leanprover.github.io/>.

[^Picus]: Isil Dillig et al. **Picus: soundness-checking for ZK
circuits**. <https://github.com/Veridise/Picus>.

[^Ecne]: **Ecne: An engine for verifying the soundness of R1CS
constraints**.
<https://0xparc.org/blog/ecne>.

[^ProverHW]: Ingonyama, Supranational, and ICICLE — surveys of
GPU/FPGA prover hardware. <https://github.com/ingonyama-zk/papers>.
