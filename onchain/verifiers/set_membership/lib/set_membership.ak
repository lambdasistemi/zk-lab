//// Set-membership verifier skeleton.
////
//// TODO: fill in on-chain verification logic once a backend
//// (Groth16 / BBS+ / Halo2) is wired through the DSL.
////
//// This module is experimental. Trusted setups produced during
//// development are toy-grade and MUST NOT be reused in production
//// (FR-011 of specs/001-set-membership/).

pub type SetMembershipProof {
  placeholder: Int,
}

pub fn verify(_proof: SetMembershipProof) -> Bool {
  // TODO: replace with real verification once backends land.
  True
}
