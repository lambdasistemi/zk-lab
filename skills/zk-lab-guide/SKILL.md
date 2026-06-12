---
name: zk-lab-guide
description: >-
  Guide for working in the lambdasistemi/zk-lab repository — an
  intention-driven zero-knowledge DSL targeting Plutus (Cardano).
  Load this when a task mentions zk-lab, the set-membership primitive,
  the Intention GADT, ZK.DSL.SetMembership, ZK.Canonicalize, the
  canonicalTag / domain tag "zk-lab/set-membership/v1", the shared
  test-vector store under vectors/set-membership/ (positive/ +
  tampering/ + schema.json), the Lean spec lean/ZKLab/SetMembership.lean
  (theorems P1-P6, sorry-ed), the QuickCheck module
  ZK.DSL.Properties.SetMembership (prop_completeness, prop_soundness,
  prop_zero_knowledge, prop_canonicalization_idempotent,
  prop_empty_rejected, prop_proofs_unlinkable), the property-parity gate
  (check-property-parity.sh, SC-003), the parity matrix, BackendTag
  (Groth16/BBSPlus/Halo2), the Aiken verifier skeleton under
  onchain/verifiers/set_membership/, the semantic graph (data/rdf/zkp.ttl),
  the Nix flake checks/apps, or the just recipes (build-dsl, test-dsl,
  check-vectors, check-property-parity, build-lean, build-aiken-skeleton,
  docs-strict, CI). Use it to navigate the code, run the gates, use the
  DSL, or answer user questions about what zk-lab is and what it ships.
---

# zk-lab guide

zk-lab expresses a privacy statement once in a high-level DSL and
realizes it across ZK backends with parity. It is experimental (toy
setups only). Today only the **set-membership** primitive exists, as a
**DSL-only slice** — no Groth16/BBS+/Halo2 backend has landed, so every
parity-matrix cell is a gap.

## Repository map

| Path | Purpose |
|------|---------|
| `offchain/` | Haskell library `zk-lab` (cabal). The DSL + properties + vector loader. |
| `offchain/src/ZK/DSL/SetMembership.hs` | Public DSL surface — the only module an author imports. Re-exports the types and `member`. |
| `offchain/src/ZK/DSL/SetMembership/Types.hs` | Nominal types: `Element`, `Set`, `Value`, `SetCommitment s`, `Proof s` (internal; re-exported). |
| `offchain/src/ZK/DSL/Intention.hs` | `Intention` GADT indexed by `StatementFamily`; constructor `SetMember`. |
| `offchain/src/ZK/Backend/Tag.hs` | `BackendTag` kind (`Groth16`, `BBSPlus`, `Halo2`) — phantom tag on commitments/proofs. |
| `offchain/src/ZK/Canonicalize.hs` | `domainTag`, `canonicalSetBytes`, `canonicalTag` (SHA-256 cross-check, not a commitment). |
| `offchain/src/ZK/DSL/Verdict.hs` | `Verdict = Accept \| Reject`. |
| `offchain/src/ZK/DSL/Properties/SetMembership.hs` | QuickCheck generators + `prop_*` (P1–P6). |
| `offchain/src/ZK/Vectors/SetMembership.hs` | Loader/decoders for the vector store (`PositiveCase`, `TamperingCase`, `Mutation`). |
| `offchain/test/` | hspec: `SetMembershipSpec`, `Vectors/SetMembershipSpec` (`Spec.hs` via hspec-discover). |
| `offchain/scripts/` | `check-property-parity.sh` (SC-003), `check-docs-disclaimers.sh` (FR-011). |
| `lean/ZKLab/SetMembership.lean` | Formal spec: theorems P1–P6, bodies `sorry` (specifications, not proofs). |
| `onchain/verifiers/set_membership/` | Aiken verifier skeleton (`lib/set_membership.ak`, `aiken.toml`). |
| `vectors/set-membership/` | Shared store: `schema.json`, `positive/*.json`, `tampering/*.json`. |
| `data/` | Semantic graph: `rdf/zkp.ttl`, `config.json`, `queries.json` (graph-browser). |
| `docs/` + `mkdocs.yml` | MkDocs site (published to GitHub Pages). |
| `specs/001-set-membership/` | SpecKit spec/plan/tasks/contracts/research/quickstart. |
| `nix/` + `flake.nix` + `justfile` | Flake checks/apps and the recipe wrappers. |

## Build, test, run

Enter `nix develop` first (GHC 9.10, cabal, fourmolu, hlint, cabal-fmt,
just). Recipes:

```bash
just build-dsl              # cabal build all -O0
just test-dsl              # hspec + QuickCheck (properties + vector loader)
just check-vectors          # JSON-schema + canonicalization gate
just check-property-parity  # Lean <-> QuickCheck 1:1 (SC-003)
just build-lean             # lake build of the Lean spec
just build-aiken-skeleton   # aiken check of the verifier skeleton
just check-docs-disclaimers # block production-readiness claims (FR-011)
just docs-strict            # mkdocs build --strict
just format / just hlint    # fourmolu+cabal-fmt+nixfmt / hlint
just CI                     # full local mirror of CI
```

The Lean/Aiken/JSON-schema toolchains live only in the sandboxed flake
apps (`nix run .#lean`, `.#aiken-skeleton`, `.#vectors`, …); the
recipes shell out to them, so the dev shell stays small. Flake checks:
`nix build .#checks.x86_64-linux.<offchain|format|hlint|lean|aiken-skeleton|vectors|property-parity|docs-disclaimers|docs-strict>`.

## Navigating the code

- **Entry point for the DSL**: `ZK.DSL.SetMembership` re-exports
  everything an author needs; `member :: Value -> SetCommitment s ->
  Intention 'SetMembership` is the helper. The `Intention` type and
  `StatementFamily` live in `ZK.DSL.Intention`; backend tags in
  `ZK.Backend.Tag`.
- **A `Set` is only built via `fromList`** — it returns `Nothing` on
  `[]` and canonicalizes (lex-sort + dedup) otherwise. There is no
  public `Set` constructor; this enforces properties P4/P5.
- **Adding a property** means editing both `lean/ZKLab/SetMembership.lean`
  (a `theorem` inside the `-- ## Parity-tracked properties ##` section)
  and `ZK.DSL.Properties.SetMembership` (a matching `prop_*`), plus the
  mapping table in `specs/001-set-membership/contracts/properties.md`.
  `check-property-parity.sh` fails the build on drift.
- **Adding a vector** is a single JSON file under
  `vectors/set-membership/positive/` or `/tampering/` matching
  `schema.json`; positive cases also have to satisfy the
  canonicalization check in `ZK.Vectors.SetMembershipSpec`.
- **The backend layer does not exist yet** — there is no `Backend`
  class and no `offchain/cbits/`. Backend docs under
  `docs/implementation/` are forward-looking plans.

## Using the DSL

```haskell
import ZK.Backend.Tag (BackendTag (Groth16))
import ZK.DSL.Intention (Intention, StatementFamily (SetMembership))
import ZK.DSL.SetMembership
    (Element (..), SetCommitment, Value (..), fromList, member)

claim :: Maybe (Intention 'SetMembership)
claim = do
    theSet <- fromList [Element "alice", Element "bob", Element "charlie"]
    let commit :: SetCommitment 'Groth16
        commit = commitSet theSet   -- commitSet ships with a backend
    pure (Value (Element "alice") `member` commit)
```

`member` is backend-polymorphic; the backend name appears only in the
phantom tag on `SetCommitment`/`Proof`. `commitSet`, `prove`, and
on-chain verification are not callable until a backend lands.

## Answering questions

- **"What is zk-lab / what does it do?"** → README "What is this" and
  `docs/index.md`. Intention-driven ZK DSL for Plutus; DSL is the
  product, backends are plumbing; experimental, toy setups only.
- **"What actually works today?"** → only the set-membership DSL slice
  (surface, canonicalizer, Lean+QuickCheck properties, vector store,
  Aiken skeleton). No backend. Confirm via the parity matrix
  (`docs/dsl/parity-matrix.md`) — all gaps.
- **"How do set-membership semantics / properties work?"** →
  `docs/dsl/primitives/set-membership.md` and
  `specs/001-set-membership/contracts/properties.md` (P1–P6 mapping).
- **"What's the test-vector format?"** → `docs/dsl/test-vectors.md` and
  `vectors/set-membership/schema.json`.
- **"How do I build/test/run it?"** → README Install/Development or the
  Build, test, run section above; commands are in the `justfile`.
- **"Is it production-ready?"** → No. Experimental, toy trusted setups
  only; FR-011 forbids production claims and CI enforces it.
- **"What is the semantic graph?"** → `docs/semantic-graph/` over
  `data/rdf/zkp.ttl`, viewed through graph-browser.
