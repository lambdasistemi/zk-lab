{- |
Module      : ZK.DSL.Verdict
Description : The two-valued result of verifying an intention.
Copyright   : (c) lambdasistemi, 2026
License     : Apache-2.0

Every intention evaluator — Haskell reference, each ZK backend,
the Aiken on-chain verifier — returns a 'Verdict'. Keeping the
type this narrow is deliberate: any richer structure (error
codes, witnesses, counterexamples) would leak through the ZK
barrier and break the zero-knowledge property P3 of
@specs/001-set-membership/contracts/properties.md@.
-}
module ZK.DSL.Verdict
    ( Verdict (..)
    ) where

-- | Accept or reject. No other inhabitants.
data Verdict
    = Accept
    | Reject
    deriving stock (Eq, Show)
