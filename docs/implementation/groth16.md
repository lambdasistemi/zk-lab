# Groth16 backend

!!! note "Status"
    Not yet ported. This page describes the planned copy-over from
    `harvest-015`.

## Source

- Rust FFI crate: `harvest-015/offchain/cbits/groth16-ffi/`
  (wraps `ark-groth16`).
- Haskell modules: `harvest-015/offchain/src/Cardano/Groth16/*`
  (`Types`, `FFI`, `Prove`, `Compress`, `Serialize`).
- Example circuit: `harvest-015/circuits/voucher_spend.circom`.

## Target layout

```
offchain/cbits/groth16-ffi/          -- Rust crate, minimally reshaped
offchain/src/ZK/Groth16/
    Types.hs
    FFI.hs
    Prove.hs
    Verify.hs
    Serialize.hs
    Backend.hs      -- implements the DSL backend interface
circuits/voucher-spend/
    circuit.circom
    README.md       -- statement, provenance, toy setup notes
onchain/lib/groth16/
    verify.ak       -- Plutus verifier (via BN254 builtins)
```

The reshaping is:

- move `Cardano.Groth16.*` → `ZK.Groth16.*`;
- add a `Backend.hs` implementing the uniform backend interface
  defined in [DSL / backends](../dsl/backends.md);
- attach Haddock module headers with `dcterms:source`-style
  attribution to the originating commit in `harvest-015`.

## Parity responsibilities

This backend must pass the shared test vectors for any intention
it claims ✅ on in the parity matrix. Initial claim on landing:
**voucher spend** ✅; everything else starts as ⚠️ gap.

## Open questions

- Trusted setup ergonomics in tests — where does the toy `.ptau`
  live, how is it regenerated, and how is reuse prevented?
- Public-input commitment for large inputs — needed or not for
  the voucher-spend circuit at current parameters.
