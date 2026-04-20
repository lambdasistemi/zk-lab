{- |
Module      : ZK.Backend.Tag
Description : Phantom tag identifying a ZK backend at the type level.
Copyright   : (c) lambdasistemi, 2026
License     : Apache-2.0

'BackendTag' is a closed kind of identifiers used as phantom
parameters on backend-linked types like @SetCommitment s@ and
@Proof s@. Keeping the tag on the type lets the type checker
prevent accidentally verifying a Groth16 proof against a BBS+
commitment and vice versa.

No term-level constructors live here; the tag is reached only
through @-XDataKinds@ at the type level.
-}
module ZK.Backend.Tag
    ( BackendTag (..)
    ) where

{- | Identifier for each ZK backend. Promoted to the type level via
@-XDataKinds@. Expand this when new backends land — every use
site will be told by the compiler to grow a new case.
-}
data BackendTag
    = Groth16
    | BBSPlus
    | Halo2
    deriving stock (Eq, Show)
