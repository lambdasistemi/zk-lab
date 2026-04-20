# Quickstart: Set Membership (DSL author)

**Audience**: A new contributor who wants to express a set-membership
statement in the DSL. You do not need to know any cryptography to
finish this quickstart.

**Time budget**: 30 minutes (SC-001). If this takes longer, that's a
bug — file an issue.

## Prerequisites

- Clone the repo: `git clone https://github.com/lambdasistemi/zk-lab`.
- Enter the dev shell: `nix develop`. This gives you GHC, `cabal`,
  `fourmolu`, `hlint`, and `lake` (for the Lean property module).
- Do not install a Rust toolchain yet. Backends live behind FFI that
  does not exist in this slice; you will not need Rust until a backend
  PR lands.

## Step 1 — Read the intention

The DSL surface lives in one module:
`offchain/src/ZK/DSL/SetMembership.hs`. Read it end to end; it is
<100 lines. See [contracts/intention.md](./contracts/intention.md) for
the public API and a worked example.

You should come away with:

- How to turn a list of `ByteString`s into a `Set`.
- How to construct an `Intention 'SetMembership` using `member`.
- What a `SetCommitment s` is, and why the `s` is a phantom tag.

## Step 2 — Write the intention

Create a scratch file `scratch/my-claim.hs`:

```haskell
import ZK.DSL.SetMembership

myClaim :: Maybe (Intention 'SetMembership)
myClaim = do
    theSet <- fromList
        [ Element "alice"
        , Element "bob"
        , Element "charlie"
        ]
    let commit :: SetCommitment 'SomeBackend
        commit = error "plug in a real commitment when a backend lands"
    pure $ Value (Element "alice") `member` commit
```

`Value (Element "alice") `member` commit` reads like English. That is
the success signal for SC-001: intention-first, backend-free.

## Step 3 — Point at the shared vectors

Open `vectors/set-membership/positive/small-set.json`. It contains a
`set`, a `canonicalSet`, a `canonicalTag`, a `value`, and an
`expectedVerdict: accept`. You should be able to map every field to a
concept you just read about in Step 1. If you can't, that is a
documentation bug.

See [contracts/vectors.md](./contracts/vectors.md) for the full
schema.

## Step 4 — Read the property mapping

Open [contracts/properties.md](./contracts/properties.md). The table
maps six Lean theorems to six QuickCheck properties. Every DSL author
should know which properties exist, even if they never touch Lean:

- `completeness`, `soundness`, `zeroKnowledge` — the three GMR 1989
  properties.
- `canonicalization`, `emptyRejected` — DSL-layer guarantees that hold
  without any backend.
- `proofUnlinkability` — a consequence of zero-knowledge, tested
  statistically in QuickCheck.

If you are adding a backend, read `lean/ZKLab/SetMembership.lean`
alongside this file; the `sorry`s in that module are your to-do list.

## Step 5 — Run the checks that do exist

From the repo root:

```bash
just build-dsl        # Haskell build for the DSL (offchain/)
just test-dsl         # Haskell test — runs QuickCheck properties against
                      # any backend registered in the test suite
just check-vectors    # JSON Schema + canonicalization checks over
                      # vectors/set-membership/
just build-lean       # lake build for lean/ZKLab/SetMembership.lean
```

All four pass without any backend installed. That is the point of a
DSL-only slice.

## What you did not have to do

- Pick a curve.
- Touch an R1CS, a PLONK custom gate, or a BBS+ generator.
- Write a Plutus script.
- Install a Rust toolchain.

When the first backend PR lands, adding backend support is a *flag*
flip in the test runner — not a rewrite of your intention.

## Where to go next

- **Add a tampering vector**: edit a new file under
  `vectors/set-membership/tampering/` following the schema in
  [contracts/vectors.md](./contracts/vectors.md). CI re-runs every
  parity-complete backend against your new case.
- **Sharpen a property**: propose a new theorem in
  `lean/ZKLab/SetMembership.lean` with a matching `prop_*` in the
  QuickCheck module. Update the mapping table in
  [contracts/properties.md](./contracts/properties.md).
- **Port a backend**: read the backend-PR template (arrives with the
  Groth16 port from `harvest-015`). The parity-matrix row for this
  primitive is where your PR starts.
