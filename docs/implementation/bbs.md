# BBS+ backend

!!! note "Status"
    Not yet ported. This page describes the planned copy-over from
    `cardano-bbs`.

## Source

- Rust FFI crate: `cardano-bbs/offchain/cbits/zkryptium-ffi/`
  (wraps `zkryptium`).
- Haskell modules: `cardano-bbs/offchain/src/Cardano/BBS/*`
  (`Credential`, `FFI`, `KeyGen`, `Proof`, `Serialize`, `Verify`).
- Aiken verifier: `cardano-bbs/onchain/lib/bbs/{generators,
  types, verify}.ak`.

## Target layout

```
offchain/cbits/zkryptium-ffi/        -- Rust crate, minimally reshaped
offchain/src/ZK/BBS/
    Credential.hs
    FFI.hs
    KeyGen.hs
    Proof.hs
    Verify.hs
    Serialize.hs
    Backend.hs       -- implements the DSL backend interface
onchain/lib/bbs/
    generators.ak
    types.ak
    verify.ak
```

The reshaping mirrors Groth16: move the module tree under
`ZK.BBS.*`, add `Backend.hs`, carry attribution in module headers.

## Parity responsibilities

Initial claim on landing: **selective disclosure** ✅; everything
else starts as ⚠️ gap. Range proofs over BBS+ are reasonably
tractable and likely to land second.

## Open questions

- Credential lifecycle: issuance, revocation, rotation — scoped in
  or scoped out for the lab? Initial answer: **scoped out**; the
  backend handles proofs of possession over an existing credential.
- Generator derivation: standard-compliant vs convenience; which
  does the zkryptium wrapper expose by default.
