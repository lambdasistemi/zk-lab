# Culture

Zero-knowledge is not a monolith. It is a stack of ideas proposed by
specific people in specific decades for specific reasons, deployed
(or not) by specific communities who brought their own politics with
them. This chapter situates the field.

!!! abstract "Scheme filter"
    The graph below is restricted to
    `ch:Culture` — the cultural-history viewpoint onto the shared
    graph. Use it to walk from papers to deployments to institutions
    and the trust models they ratify.

!!! info "Embed status"
    The embedded graph below loads the full `zk-lab` graph; pick
    *Culture* from the view/filter picker once inside.
    Per-chapter URL filtering is tracked upstream as
    [graph-browser#68](https://github.com/lambdasistemi/graph-browser/issues/68).

<iframe
  title="zk-lab semantic graph — culture view"
  src="https://lambdasistemi.github.io/graph-browser/?repo=lambdasistemi/zk-lab&view=culture"
  width="100%" height="600" loading="lazy"
  style="border: 1px solid #444; border-radius: 6px;">
</iframe>

## What the graph says

The origin paper — Goldwasser–Micali–Rackoff 1985 [^GMR85] — is the
root node. From it descend the non-interactive variants of the late
1980s [^BFM88], Groth's 2016 construction [^Groth16], and the
deployment wave that normalized SNARKs in production. Zcash
(2016) [^Zcash] first made zk-SNARKs load-bearing at scale, and its
Sapling upgrade (2018) made Groth16 mainstream. The Ethereum rollup
ecosystem then became the economic centre of gravity for verifier
optimization and ceremony engineering [^EFCeremony].

Cardano is a younger node. Plutus V3 exposes BN254 and BLS12-381
builtins [^CIP381], making on-chain Groth16 and BBS+ verifiers
buildable today. This lab sits there.

Ceremonies are the cultural artifact most worth studying. A trusted
setup is *cryptographically* a distributed computation; *socially* it
is a governance ritual. The Ethereum KZG ceremony [^EFCeremony]
involved 140,000+ participants precisely because the legitimacy of
the resulting trust root is proportional to the visibility of the
ritual.

## Sources

[^GMR85]: Goldwasser, S.; Micali, S.; Rackoff, C. (1985). **The
Knowledge Complexity of Interactive Proof-Systems**. STOC '85.
[DOI:10.1145/22145.22178](https://doi.org/10.1145/22145.22178).

[^BFM88]: Blum, M.; Feldman, P.; Micali, S. (1988). **Non-Interactive
Zero-Knowledge**. SIAM Journal on Computing.
[DOI:10.1137/0220068](https://doi.org/10.1137/0220068).

[^Groth16]: Groth, J. (2016). **On the Size of Pairing-Based
Non-interactive Arguments**. EUROCRYPT 2016.
[IACR 2016/260](https://eprint.iacr.org/2016/260).

[^Zcash]: Ben-Sasson, E. et al. (2014). **Zerocash: Decentralized
Anonymous Payments from Bitcoin**. IEEE S&P.
<https://doi.org/10.1109/SP.2014.36>.

[^EFCeremony]: Ethereum Foundation. **KZG Ceremony**.
<https://ceremony.ethereum.org/>.

[^CIP381]: Cardano. **CIP-0381: Plutus Built-in for BLS12-381**.
<https://cips.cardano.org/cip/CIP-0381>.
