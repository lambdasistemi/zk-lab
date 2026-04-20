{- |
Module      : ZK.DSL.SetMembership
Description : DSL surface for membership-in-a-finite-set intentions.
Copyright   : (c) lambdasistemi, 2026
License     : Apache-2.0

The /only/ module a DSL author imports to express
@Value v \`member\` commitment@. No circuits, no gates, no curves —
just sets, commitments, and the intention that links them.

Internally the nominal types live in "ZK.DSL.SetMembership.Types"
and the GADT constructor lives in "ZK.DSL.Intention"; this module
re-exports both so end users have a single import.

Citations (principle 7a; registry in
@docs\/dsl\/citations.md@):

* __Membership-by-path formulation__ — Merkle, /A Digital Signature
  Based on a Conventional Encryption Function/ (CRYPTO \'87).
  DOI 10.1007\/3-540-48184-2_32. Provides the backend-independent
  shape of a set-membership statement ("the element is present in
  the set whose commitment is C").
* __Completeness \/ soundness \/ zero-knowledge framing__ —
  Goldwasser, Micali, Rackoff, /The Knowledge Complexity of
  Interactive Proof Systems/. SIAM J. Comput. 18(1) (1989).
  DOI 10.1137\/0218012. Supplies the P1\/P2\/P3 properties in
  @specs\/001-set-membership\/contracts\/properties.md@.

Canonicalization (sort + dedup, SHA-256-tagged) is specified in
research.md decision D-05 and implemented in "ZK.Canonicalize".
-}
module ZK.DSL.SetMembership
    ( -- * Set construction
      Element (..)
    , Set
    , fromList
    , toList

      -- * Witness and commitment
    , Value (..)
    , SetCommitment (..)
    , Proof (..)

      -- * Intention helper
    , member
    ) where

import ZK.DSL.Intention
    ( Intention (SetMember)
    , StatementFamily (SetMembership)
    )
import ZK.DSL.SetMembership.Types
    ( Element (..)
    , Proof (..)
    , Set
    , SetCommitment (..)
    , Value (..)
    , fromList
    , toList
    )

{- | Express "this value is a member of the set behind this
commitment." Reads naturally as English prose:

@
claim = Value element \`member\` commitment
@

Identical to the 'SetMember' constructor of 'Intention'; the
function form exists purely to make call sites resemble a sentence.
-}
member
    :: Value
    -> SetCommitment s
    -> Intention 'SetMembership
member = SetMember
