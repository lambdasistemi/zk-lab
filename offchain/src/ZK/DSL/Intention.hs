{- |
Module      : ZK.DSL.Intention
Description : Closed GADT for intentions, indexed by statement family.
Copyright   : (c) lambdasistemi, 2026
License     : Apache-2.0

An 'Intention' is the user-facing statement the DSL compiles
into a verifier. The type is indexed by a 'StatementFamily' so
downstream consumers (the Aiken verifier, the reference
evaluator, the property QuickChecks) can dispatch on the family
at the type level.

Constructors land per user story. 'SetMember' arrives in
Phase 3 US1 (task T018 of
@specs\/001-set-membership\/tasks.md@); subsequent families add
their own constructors and their own 'StatementFamily' variant.
-}
module ZK.DSL.Intention
    ( StatementFamily (..)
    , Intention (..)
    ) where

import ZK.DSL.SetMembership.Types
    ( SetCommitment
    , Value
    )

{- | Kind of statement families. Each downstream user story adds
one constructor (and one GADT branch) here.
-}
data StatementFamily
    = SetMembership
    deriving stock (Eq, Show)

{- | Closed GADT of intentions indexed by statement family.

The @f@ parameter is consumed at the type level; at runtime each
constructor carries only the data the Haskell reference evaluator
and the backends need. See
@specs\/001-set-membership\/contracts\/intention.md@ for the
per-family shape.
-}
data Intention (f :: StatementFamily) where
    {- | Assert that a private 'Value' belongs to the set whose
    canonical commitment is 'SetCommitment'. The backend tag @s@
    keeps the commitment linked to the backend that produced it.
    -}
    SetMember
        :: Value
        -> SetCommitment s
        -> Intention 'SetMembership
