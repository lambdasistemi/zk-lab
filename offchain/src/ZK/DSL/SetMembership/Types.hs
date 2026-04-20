{- |
Module      : ZK.DSL.SetMembership.Types
Description : Internal module holding the nominal types of the set-membership DSL.
Copyright   : (c) lambdasistemi, 2026
License     : Apache-2.0

Split out of "ZK.DSL.SetMembership" to break an import cycle with
"ZK.DSL.Intention": the 'Intention' GADT carries 'Value' and
'SetCommitment' fields, while the @member@ helper next to them
refers to the 'Intention' constructor. This module holds the
data types only — no intention, no helper — so the import graph
stays a tree.

Not part of the public API. Users import "ZK.DSL.SetMembership",
which re-exports everything here verbatim.

Citations: see "ZK.DSL.SetMembership".
-}
module ZK.DSL.SetMembership.Types
    ( Element (..)
    , Set
    , unSet
    , fromList
    , toList
    , Value (..)
    , SetCommitment (..)
    , Proof (..)
    ) where

import Data.ByteString (ByteString)
import Data.List (sort)
import Data.Set qualified as Set

import ZK.Backend.Tag (BackendTag)

{- | Uninterpreted bytes standing in for a set element. The DSL
makes no encoding assumption — a hash digest, a raw address, an
ASCII username all fit — so downstream backends can pick the
representation most natural to their arithmetic.
-}
newtype Element = Element ByteString
    deriving stock (Eq, Ord, Show)

{- | A finite, canonicalized, non-empty collection of 'Element's.

Only built via 'fromList' so the canonical-form invariant — sorted
lexicographically, deduplicated, non-empty — is unforgeable outside
this module.
-}
newtype Set = Set (Set.Set Element)
    deriving stock (Eq, Show)

{- | Escape hatch for internal consumers (the canonicalizer and
the test suite) that need the underlying @Data.Set.Set@. The
re-exported public API does not expose this.
-}
unSet :: Set -> Set.Set Element
unSet (Set s) = s

{- | Build a 'Set' from a list of 'Element's.

Returns 'Nothing' when the input is empty — empty sets carry no
membership statement, so the DSL rejects them at construction time
(property P5 of @contracts\/properties.md@).

Dedup + lex sort happen for free via @Data.Set@'s @fromList@,
matching canonicalization decision D-05 of @research.md@.
-}
fromList :: [Element] -> Maybe Set
fromList [] = Nothing
fromList xs = Just (Set (Set.fromList xs))

{- | Enumerate a 'Set' in canonical (lexicographic) order. Inverse
of 'fromList' up to re-canonicalization
(@fromList . toList . fromList ≡ fromList@, property P4).
-}
toList :: Set -> [Element]
toList (Set s) = sort (Set.toList s)

{- | The prover's private witness: the element whose membership is
being asserted. Never revealed to a verifier.
-}
newtype Value = Value Element
    deriving stock (Eq, Show)

{- | Opaque commitment to a 'Set'. The payload bytes are backend-
specific (a Merkle root, a Pedersen vector, a BBS+ signature …),
which is why the type is phantom-tagged by the backend that
produced it. 'Eq' and 'Show' compare bytes only; they carry no
cryptographic meaning.
-}
newtype SetCommitment (s :: BackendTag) = SetCommitment ByteString
    deriving stock (Eq, Show)

{- | A backend-emitted proof of membership. Opaque; the payload is
the backend's business. The tag prevents pairing a Groth16 proof
with a BBS+ commitment at the type level.
-}
newtype Proof (s :: BackendTag) = Proof ByteString
    deriving stock (Eq, Show)
