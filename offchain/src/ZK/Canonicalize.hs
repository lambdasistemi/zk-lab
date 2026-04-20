{- |
Module      : ZK.Canonicalize
Description : Backend-independent canonical encoding + tag for sets.
Copyright   : (c) lambdasistemi, 2026
License     : Apache-2.0

The DSL canonicalizes a 'Set' before any backend gets its hands on
it. Two functions suffice — one to produce the canonical byte
serialization, one to produce a domain-separated SHA-256 tag that
every backend can re-derive and cross-check in the shared vector
store.

This is not the cryptographic commitment. It is a
/canonicalization-check value/: vectors assert "every backend
should have reached this same canonical form before applying its
own commitment scheme." Divergence surfaces as a test failure
instead of a silent soundness bug.

See research.md decision D-05 for the rationale (lex sort + dedup,
SHA-256 with a versioned domain-separation tag).
-}
module ZK.Canonicalize
    ( domainTag
    , canonicalSetBytes
    , canonicalTag
    ) where

import Crypto.Hash.SHA256 qualified as SHA256
import Data.ByteString (ByteString)
import Data.ByteString qualified as BS

import ZK.DSL.SetMembership (Element (..), Set, toList)

{- | Versioned domain-separation tag. Bumped alongside any
breaking change to 'canonicalSetBytes' so that a future re-hash
cannot collide with today's.
-}
domainTag :: ByteString
domainTag = "zk-lab/set-membership/v1"

{- | The canonical byte serialization of a 'Set': the
concatenation of its lex-ordered, deduplicated elements.

No length prefix, no separator byte. 'Set' construction
('ZK.DSL.SetMembership.fromList') already guarantees lex order
and dedup, so this function is a pure observation; it never
fails.

For raw bytes plus the domain tag, see 'canonicalTag'.
-}
canonicalSetBytes :: Set -> ByteString
canonicalSetBytes = BS.concat . fmap unElement . toList
  where
    unElement (Element b) = b

{- | SHA-256 of @domainTag ++ canonicalSetBytes@. The 32-byte
digest published next to every positive test vector. Backends
re-compute it before applying their own commitment scheme; a
mismatch means the backend saw a different canonical form, not a
cryptographic failure.
-}
canonicalTag :: Set -> ByteString
canonicalTag s = SHA256.hash (domainTag <> canonicalSetBytes s)
