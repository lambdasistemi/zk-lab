# Backends as plumbing

Backends exist to make intentions real. They are not the story; they
are the story's set dressing.

## The uniform backend interface

Every backend exposes the same Haskell interface (sketch):

```haskell
class Backend b where
    data ProvingKey b
    data VerifyingKey b
    data Proof b

    setup    :: Intention -> IO (ProvingKey b, VerifyingKey b)
    prove    :: ProvingKey b -> Witness -> PublicInputs -> IO (Proof b)
    verify   :: VerifyingKey b -> PublicInputs -> Proof b -> Bool
    plutusVK :: VerifyingKey b -> PlutusScript
```

The real interface will be richer — binding context, nullifiers,
credential lifecycle — but the shape is: one call path per
intention, identical signature across backends. *If the backend
can't fit, it's a gap, not an exception in the interface.*

## The three backends

- **Groth16** (arkworks via `groth16-ffi`). Per-circuit setup. Best
  proof size and on-chain cost. Rigid statement shape.
- **BBS+** (zkryptium via `zkryptium-ffi`). No per-statement setup.
  Specialized for credential disclosure. On-chain verifier exists
  via Plutus BLS12-381 builtins.
- **Halo2** (PSE via `halo2-ffi`, planned). Universal setup,
  expressive PLONKish. On-chain verifier is open research.

## Where cryptography lives

In Rust crates under `offchain/cbits/<backend>-ffi/` with a narrow C
ABI. Haskell owns:

- DSL types
- serialization / deserialization
- error sum types
- Plutus verifier emission

Rust owns:

- field and curve arithmetic
- proving and verification algorithms
- setup artifacts

Adding a new DSL primitive should almost never require changes to
the Rust crates. When it does, that is a signal the primitive may be
leaky across abstraction boundaries.
