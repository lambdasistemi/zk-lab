# Contract: DSL Intention Surface

**Feature**: [../spec.md](../spec.md) | **Plan**: [../plan.md](../plan.md)

The *user-visible* Haskell surface for expressing set membership. This
is what every DSL author reads; any backend is expected to compile it
unchanged.

## Module

`offchain/src/ZK/DSL/SetMembership.hs`

## Public API

```haskell
-- | An element of a set. Uninterpreted bytes; the DSL makes no
-- encoding assumptions.
newtype Element = Element ByteString
    deriving (Eq, Ord, Show)

-- | A finite, deduplicated collection of 'Element's. Constructed only
-- via 'fromList' to guarantee canonicalization.
newtype Set = Set (Data.Set.Set Element)
    deriving (Eq, Show)

-- | Canonicalize an input list into a 'Set'. Sorts and dedupes.
-- Returns 'Nothing' for empty input (empty sets are rejected at
-- construction time, per spec §Edge Cases).
fromList :: [Element] -> Maybe Set

-- | The prover's private witness element. Never revealed to a
-- verifier.
newtype Value = Value Element
    deriving (Eq, Show)

-- | Opaque set commitment. Each backend tag 's' refines the payload
-- bytes (Merkle root, Pedersen vector, BBS+ signature, ...).
newtype SetCommitment (s :: BackendTag) = SetCommitment ByteString
    deriving (Eq, Show)

-- | DSL intention. Parameterized by a statement-family tag so new
-- primitives can be added without reshaping existing constructors.
data Intention (f :: StatementFamily) where
    SetMember
        :: Value
        -> SetCommitment s
        -> Intention 'SetMembership

-- | Convenience helper. Reads as English prose.
member :: Value -> SetCommitment s -> Intention 'SetMembership
member = SetMember
```

## Example

```haskell
Just theSet <- pure $ fromList
    [ Element "alice"
    , Element "bob"
    , Element "charlie"
    ]

let commit :: SetCommitment 'Groth16
    commit = commitSet theSet   -- provided by the Groth16 backend

let claim :: Intention 'SetMembership
    claim = Value (Element "alice") `member` commit
```

The same `claim` expression is compiled by *every* parity-complete
backend. No backend appears in the DSL author's code.

## What is deliberately absent

- No `Circuit`, `R1CS`, `Gate`, or `Setup` type.
- No curve selection.
- No backend-specific witness type. The `Witness` type family lives
  in a backend-internal module, not on the DSL user's import path.

Rejecting these is not an oversight. They are constitutional
invariants (principles 1 and 5): the DSL surface stays narrow so the
statement remains the product.

## Backend interpretation contract

A backend provides, in its own module (not imported by the DSL user):

```haskell
class Backend (s :: BackendTag) where
    commitSet :: Set -> SetCommitment s
    prove
        :: Set
        -> Value
        -> Intention 'SetMembership
        -> Either ProverError (Proof s)
    verifyOff
        :: SetCommitment s
        -> Proof s
        -> Intention 'SetMembership
        -> Verdict
```

The on-chain verifier is a separate Aiken module under
`onchain/verifiers/set_membership/<backend>.ak`; its Plutus
interpretation of `verifyOff` is the Plutus-reachable counterpart.

This contract is named here for completeness; concrete instances
arrive in backend PRs.
