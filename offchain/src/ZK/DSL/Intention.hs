{- |
Module      : ZK.DSL.Intention
Description : Closed GADT for intentions, indexed by statement family.
Copyright   : (c) lambdasistemi, 2026
License     : Apache-2.0

An 'Intention' is the user-facing statement the DSL compiles
into a verifier. The type is indexed by a 'StatementFamily' so
downstream consumers (e.g. the Aiken verifier, the reference
evaluator, the property QuickChecks) can dispatch on the family
at the type level.

Phase 2 lands the scaffolding only: the kind of families and
the empty GADT. Each user story fills in its own constructor —
'SetMembership' receives its @SetMember@ constructor in
Phase 3 US1 (task T018 of
@specs/001-set-membership/tasks.md@).
-}
module ZK.DSL.Intention
    ( StatementFamily (..)
    , Intention
    ) where

{- | Kind of statement families. Each downstream user story adds
one constructor (and one GADT branch) here.
-}
data StatementFamily
    = SetMembership
    deriving stock (Eq, Show)

{- | Closed GADT of intentions indexed by statement family.

Intentionally empty in Phase 2. Constructors land per user
story; see @docs/dsl/parity-matrix.md@ for the roadmap.
-}
data Intention (f :: StatementFamily)
