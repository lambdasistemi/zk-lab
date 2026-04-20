{- |
Module      : ZK.DSL.Placeholder
Description : Bisect-safety stub replaced by ZK.DSL.SetMembership in Phase 3.
Copyright   : (c) lambdasistemi, 2026
License     : Apache-2.0

Placeholder keeping the library non-empty while the DSL surface is
being filled in across subsequent specs and tasks. Delete the module
when @ZK.DSL.SetMembership@ ships (tasks T016–T019 of the
@001-set-membership@ slice).
-}
module ZK.DSL.Placeholder
    ( placeholder
    ) where

-- | Intentionally trivial. Kept only so the library compiles.
placeholder :: ()
placeholder = ()
