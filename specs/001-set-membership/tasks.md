---
description: "Task list for 001-set-membership — DSL-only slice"
---

# Tasks: Set Membership (DSL Slice)

**Input**: Design documents from `/specs/001-set-membership/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md,
contracts/intention.md, contracts/properties.md, contracts/vectors.md,
quickstart.md

**Tests**: Tests are REQUESTED. Constitution principle 6 (correctness
before performance) and 6a (shared test vectors) require that every
property and every tampering vector is exercised in CI. QuickCheck
tests and vector-schema checks are part of this slice.

**Organization**: Tasks are grouped by user story (US1 = intention,
US2 = vectors, US3 = dual-spec properties). All three are P1 in the
spec; US1 is MVP because it ships the surface everyone reads.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on
  incomplete tasks)
- **[Story]**: `[US1]`, `[US2]`, `[US3]` — maps to spec.md user
  stories. Setup / Foundational / Polish have no story label.

## Path Conventions

Multi-root lab (see plan.md §Project Structure):

- **Haskell DSL**: `offchain/src/ZK/DSL/...`, `offchain/test/...`
- **Lean formal**: `lean/ZKLab/...`
- **Vectors**: `vectors/set-membership/...`
- **Aiken verifier skeleton**: `onchain/verifiers/set_membership/...`
- **Docs**: `docs/dsl/...`

Every task below carries an exact file path.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Wire the multi-root layout and build drivers so every
downstream task has a place to land and a green build to start from.

- [ ] T001 Create the multi-root directory skeleton: `offchain/`, `lean/`, `vectors/set-membership/`, `onchain/verifiers/set_membership/`, `docs/dsl/primitives/`, `docs/dsl/` (for parity matrix). Empty `.gitkeep` where needed.
- [ ] T002 [P] Add `offchain/zk-lab.cabal` with library + test-suite stanzas, index-state pinned, warning set from the Haskell skill. Enumerate exposed modules explicitly: `ZK.DSL.Intention`, `ZK.DSL.SetMembership`, `ZK.DSL.Verdict`, `ZK.DSL.Properties.SetMembership`, `ZK.Backend.Tag`, `ZK.Canonicalize`, `ZK.Vectors.SetMembership`. Empty `src/ZK/DSL/Placeholder.hs` keeps the build green until Phase 2+ fills them.
- [ ] T003 [P] Add `lean/lakefile.lean` and `lean/lean-toolchain` pinning Lean 4 + Mathlib4 per research.md D-03. Empty `lean/ZKLab/Placeholder.lean` keeps `lake build` green.
- [ ] T004 [P] Add `onchain/verifiers/set_membership/aiken.toml` and `onchain/verifiers/set_membership/lib/set_membership.ak` with a `TODO` module stub only. README states "experimental, toy trusted setups only" (FR-011).
- [ ] T005 [P] Extend `flake.nix` to expose one check per root: `checks.x86_64-linux.{dsl,lean,vectors,aiken-skeleton,docs-strict}`. Build gate in CI lists all five.
- [ ] T006 [P] Extend `justfile` with recipes: `build-dsl`, `test-dsl`, `check-vectors`, `build-lean`, `build-aiken-skeleton`, `format`, `format-check`, `hlint`, `docs-strict`. These are referenced from quickstart.md.

**Checkpoint**: Repo builds and `just CI` passes with only placeholder
modules. No feature code yet.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Cross-cutting types and tooling that every user story
below depends on. Must be complete before US1, US2, or US3 can start.

**⚠️ CRITICAL**: No user story work starts until Phase 2 is green.

- [ ] T007 [P] Add the statement-family GADT scaffolding in `offchain/src/ZK/DSL/Intention.hs`: `data StatementFamily = SetMembership`, `data Intention (f :: StatementFamily) where ...` with no constructors yet. Exported but closed.
- [ ] T008 [P] Add the backend-tag kind in `offchain/src/ZK/Backend/Tag.hs`: `data BackendTag = Groth16 | BBSPlus | Halo2`. No instances, just the kind. Used as phantom tag for `SetCommitment s`, `Proof s`, etc.
- [ ] T009 [P] Add `offchain/src/ZK/DSL/Verdict.hs` with `data Verdict = Accept | Reject`. Deriving `Eq`, `Show`. No backend dependency.
- [ ] T010 Add the parity-matrix data in `docs/dsl/parity-matrix.md`: table with `set-membership` row and `Groth16 ❌ | BBSPlus ❌ | Halo2 ❌` columns. Rendered by mkdocs-strict (blocks SC-004).
- [ ] T011 Add the citation policy stub in `docs/dsl/citations.md` and cross-link it from `docs/index.md`. Every downstream file that borrows a formulation will link here (principle 7a).

**Checkpoint**: DSL kinds exist; parity matrix renders; no primitive
ships yet.

---

## Phase 3: User Story 1 — Intention (Priority: P1) 🎯 MVP

**Goal**: A DSL author can write `Value v `member` commitment` and
produce an `Intention 'SetMembership`. No cryptography, no backend.

**Independent Test**: Quickstart step 2 (the worked example in
`quickstart.md`) type-checks with `cabal build` and the API surface
matches `contracts/intention.md` exactly.

### Tests for User Story 1

- [ ] T012 [P] [US1] Unit test in `offchain/test/ZK/DSL/SetMembershipSpec.hs` that `fromList []` returns `Nothing` (P5 / edge case: empty set rejected).
- [ ] T013 [P] [US1] Unit test in `offchain/test/ZK/DSL/SetMembershipSpec.hs` that `fromList [x, x, y]` equals `fromList [y, x]` — canonicalization is permutation- and duplicate-invariant (P4).
- [ ] T014 [P] [US1] QuickCheck property `prop_canonicalization_idempotent` in `offchain/src/ZK/DSL/Properties/SetMembership.hs` (P4 from contracts/properties.md).
- [ ] T015 [P] [US1] QuickCheck property `prop_empty_rejected` in `offchain/src/ZK/DSL/Properties/SetMembership.hs` (P5).

### Implementation for User Story 1

- [ ] T016 [P] [US1] Implement `Element`, `Set`, `fromList`, `toList` in `offchain/src/ZK/DSL/SetMembership.hs` per contracts/intention.md. Lex-sort + dedup per research.md D-05.
- [ ] T017 [P] [US1] Implement `Value`, `SetCommitment (s :: BackendTag)`, `Proof (s :: BackendTag)` newtypes in `offchain/src/ZK/DSL/SetMembership.hs`.
- [ ] T018 [US1] Extend `Intention` GADT in `offchain/src/ZK/DSL/Intention.hs` with the `SetMember :: Value -> SetCommitment s -> Intention 'SetMembership` constructor. Depends on T007, T017.
- [ ] T019 [US1] Export the `member` convenience function in `offchain/src/ZK/DSL/SetMembership.hs`.
- [ ] T020 [P] [US1] Write `docs/dsl/primitives/set-membership.md`: intention → semantics (brief, links to properties.md) → implementation (links to parity-matrix.md, all ❌). Must pass `mkdocs build --strict`.
- [ ] T021 [P] [US1] Write `offchain/src/ZK/Canonicalize.hs` with `canonicalSetBytes :: Set -> ByteString` and `canonicalTag :: Set -> ByteString` (SHA-256 of domain-separation tag ++ concat) per research.md D-05.
- [ ] T022 [US1] Haddock the public API of `ZK.DSL.SetMembership` and `ZK.DSL.Intention` per Haskell skill (documentation travels with code). Cite Merkle 1987 and GMR 1989 in file-level headers.

**Checkpoint**: US1 complete. A new contributor can complete
quickstart.md steps 1-2 in under 30 minutes (SC-001).

---

## Phase 4: User Story 2 — Shared Test Vectors (Priority: P1)

**Goal**: Canonical `vectors/set-membership/` store with schema,
positive cases, tampering cases, and CI checks. Every backend will
consume this unchanged.

**Independent Test**: `just check-vectors` validates every JSON file
against `schema.json` and confirms `canonicalSet` / `canonicalTag`
for every positive case. Fails CI on drift.

### Tests for User Story 2

- [ ] T023 [P] [US2] Unit test in `offchain/test/ZK/Vectors/SetMembershipSpec.hs` that every `positive/*.json` decodes into a `PositiveCase` value per `data-model.md`.
- [ ] T024 [P] [US2] Unit test that every `tampering/*.json` decodes into a `TamperingCase` and its `baseCase` string references an existing positive case's `name`.
- [ ] T025 [P] [US2] Unit test that for every positive case, `canonicalSetBytes (fromList set) == canonicalSet` and `canonicalTag (fromList set) == declared canonicalTag` — the canonicalization check from contracts/vectors.md.

### Implementation for User Story 2

- [ ] T026 [P] [US2] Write `vectors/set-membership/schema.json` (JSON Schema 2020-12) per contracts/vectors.md, with `PositiveCase` and `TamperingCase` branches and all four `Mutation` tags.
- [ ] T027 [P] [US2] Write `vectors/set-membership/positive/singleton.json` (1-element set, value = that element, citation: Merkle 1987).
- [ ] T028 [P] [US2] Write `vectors/set-membership/positive/small-set.json` (3-element set, value = member, citation: Merkle 1987).
- [ ] T029 [P] [US2] Write `vectors/set-membership/positive/canonical-dedup.json` (input with duplicates + unsorted, canonicalSet is sorted-deduped, citation: research.md D-05).
- [ ] T030 [P] [US2] Write `vectors/set-membership/tampering/non-member.json` (mutation `non-member` referencing `small-set`, citation: GMR 1989 §soundness).
- [ ] T031 [P] [US2] Write `vectors/set-membership/tampering/wrong-commitment.json` (mutation `wrong-commitment`, citation: GMR 1989 §soundness).
- [ ] T032 [P] [US2] Write `vectors/set-membership/tampering/flipped-proof-bit.json` (mutation `flipped-proof-bit bitIndex=0`, citation: GMR 1989 §soundness).
- [ ] T033 [P] [US2] Write `vectors/set-membership/tampering/replay-across-sets.json` (mutation `replay-across-sets`, citation: GMR 1989 §soundness).
- [ ] T034 [US2] Implement `offchain/src/ZK/Vectors/SetMembership.hs` — Aeson decoders for `PositiveCase`, `TamperingCase`, `Mutation`. `loadAll :: IO ([PositiveCase], [TamperingCase])` reads from a configurable root.
- [ ] T035 [US2] Add `just check-vectors` body: run JSON Schema validation (via `nix shell nixpkgs#check-jsonschema`) and the canonicalization checker from T025.

**Checkpoint**: Vector store exists, every case decodes, every
canonicalization check passes. No backend-local fixtures anywhere
(FR-005).

---

## Phase 5: User Story 3 — Dual-specified Properties (Priority: P1)

**Goal**: Lean theorems and QuickCheck properties in 1:1
correspondence, mechanically verified by a parity-check script.

**Independent Test**: `just build-lean` succeeds, `just test-dsl`
exercises every `prop_*`, and `just check-property-parity` confirms
the mapping table in contracts/properties.md is honored.

### Tests for User Story 3

- [x] T036 [P] [US3] Property `prop_completeness` in `offchain/src/ZK/DSL/Properties/SetMembership.hs` — parameterized over a `Backend` class stub (class body empty until a backend lands, but the property is well-typed).
- [x] T037 [P] [US3] Property `prop_soundness` in the same file (bounded adversary model; for DSL-only slice it asserts `verifyOff honestCommit tamperedProof == Reject` against a stub that rejects all inputs).
- [x] T038 [P] [US3] Property `prop_zero_knowledge` in the same file (stated with a placeholder simulator and `===` distributional equality — the body is `property True` until a backend instantiates it, but the name and type signature match P3).
- [x] T039 [P] [US3] Property `prop_proofs_unlinkable` in the same file (same placeholder pattern as P6).

### Implementation for User Story 3

- [x] T040 [P] [US3] Write `lean/ZKLab/SetMembership.lean` with the six `theorem` declarations P1–P6 from contracts/properties.md. Bodies are `sorry`; statements are the specification (stub for bisect-safety per Haskell skill). File-level cite block names Merkle 1987, Tessaro-Zhu 2023, GMR 1989. (Mathlib4 pin is deferred to the first backend PR that needs `Finset` / `PMF` — the abstract-variable formulation keeps `lake build` offline inside the nix sandbox.)
- [x] T041 [US3] Implement `offchain/scripts/check-property-parity.sh` (shell, cheaper than a Haskell executable): scan `lean/ZKLab/SetMembership.lean` for theorems inside the named section `-- ## Parity-tracked properties ##` (helper lemmas outside that section are ignored), scan `offchain/src/ZK/DSL/Properties/SetMembership.hs` for `^prop_`, emit a diff against contracts/properties.md mapping table. Exit non-zero on drift (mechanizes SC-003).
- [x] T042 [US3] Add `just check-property-parity` and wire it into `just CI`. Flake app exposed as `.#property-parity`; CI gains a `property-parity` job depending on `build-gate`.
- [x] T043 [US3] Cite Merkle 1987, Tessaro-Zhu 2023, GMR 1989 in the file-level header of `offchain/src/ZK/DSL/Properties/SetMembership.hs`.

**Checkpoint**: SC-003 is mechanical: the parity script passes, Lean
builds, QuickCheck runs. Bodies of ZK properties are placeholders
until a backend instantiates them; the *shapes* exist.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final docs, CI wiring, and validation against the spec.

- [x] T044 [P] Update `README.md` with "experimental, toy trusted setups only" disclaimer and link to `docs/dsl/primitives/set-membership.md` (FR-011).
- [x] T045 [P] Update `docs/index.md` to reference the new primitive docs and the parity matrix.
- [x] T046 [P] Run `fourmolu -m check`, `hlint`, and `cabal-fmt -c` across `offchain/`; fix violations. Verified via `nix build .#checks.x86_64-linux.format .#checks.x86_64-linux.hlint`.
- [x] T047 [P] Run `mkdocs build --strict` locally; fix any link or anchor errors. Verified via `nix build .#checks.x86_64-linux.docs-strict`.
- [x] T048 Manually walk `specs/001-set-membership/quickstart.md` top to bottom. One gap surfaced: a fresh `nix develop` shell has no Hackage index, so `just build-dsl` fails with "unknown package: cryptohash-sha256" until `cabal update` is run. Fixed by pinning `index-state` in `cabal.project`. Walk under 30 minutes after the fix — SC-001 holds.
- [x] T049 [P] Update `docs/dsl/parity-matrix.md` note column with a link to each future backend's tracking issue — issues #10 (Groth16), #11 (BBS+), #12 (Halo2).
- [x] T050 [P] Post-deploy smoke test (runs in CI after `mkdocs gh-deploy`): HTTP GET `https://lambdasistemi.github.io/zk-lab/dsl/parity-matrix/` and assert 200 + "set-membership" in body (mechanizes SC-004).
- [x] T051 [P] Grep `docs/**/*.md` for production-readiness language; fail on any hit outside an explicit disclaimer block (enforces FR-011 at docs layer). Implemented as `offchain/scripts/check-docs-disclaimers.sh` + `.#docs-disclaimers` app + CI job. Whitelist of positive-claim phrases keeps third-party references legal.
- [ ] T052 Commit and open PR follow-up (or merge PR #3) after all tasks above complete.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately.
- **Phase 2 (Foundational)**: Depends on Phase 1.
- **Phase 3 (US1)**: Depends on Phase 2. MVP stopping point.
- **Phase 4 (US2)**: Depends on Phase 2. Depends on T016 (for `fromList`) and T021 (for `canonicalTag`) from US1 at the canonicalization-check task only (T025).
- **Phase 5 (US3)**: Depends on Phase 2. The `prop_*` definitions in US3 import `Set`, `Value`, `Intention` from US1 so US3 needs US1 merged (or interleaved).
- **Phase 6 (Polish)**: Depends on US1, US2, US3 complete.

### User Story Dependencies

- **US1**: Independent beyond Phase 2.
- **US2**: Independent beyond Phase 2, except T025 and T034 import from US1.
- **US3**: Independent beyond Phase 2, except `prop_*` bodies reference US1 types.

The honest ordering is US1 → US2 ∥ US3 → Polish. US2 and US3 can run
in parallel once US1's types exist.

### Within Each User Story

- Tests land with their implementation in the same commit (Haskell
  skill: docs travel with code, QuickCheck properties are
  specification, not afterthought).
- Models/types before services before endpoints doesn't apply
  cleanly here; use: types → functions → docs.
- Commit per task or per small logical group (feedback:
  `commit_frequently`, `bisect_safe_commits`).

### Parallel Opportunities

- All T00x [P] setup tasks run in parallel.
- T007, T008, T009 in Phase 2 are independent files.
- In US1: T012–T015 (tests) and T016–T017, T020–T021 (non-conflicting
  files) are all [P].
- In US2: every vector file (T026–T033) is an independent JSON file —
  a perfect `[P]` cluster.
- In US3: T036–T039 are one file each, but within the same module —
  serialize at commit time, still can draft in parallel.

---

## Parallel Example: User Story 2

```bash
# Launch all vector files in parallel:
Task: "Write vectors/set-membership/schema.json"
Task: "Write vectors/set-membership/positive/singleton.json"
Task: "Write vectors/set-membership/positive/small-set.json"
Task: "Write vectors/set-membership/positive/canonical-dedup.json"
Task: "Write vectors/set-membership/tampering/non-member.json"
Task: "Write vectors/set-membership/tampering/wrong-commitment.json"
Task: "Write vectors/set-membership/tampering/flipped-proof-bit.json"
Task: "Write vectors/set-membership/tampering/replay-across-sets.json"
```

---

## Implementation Strategy

### MVP First (US1 only)

1. Phase 1 (Setup) → Phase 2 (Foundational) → Phase 3 (US1).
2. **STOP and VALIDATE**: walk quickstart.md steps 1-2. `cabal build`
   + `cabal test` should both pass.
3. Merge a WIP PR with just US1 if time-boxed; US2 and US3 land in
   a follow-up. Parity matrix already renders (T010), so docs are
   honest about what is and isn't there.

### Incremental Delivery

1. Setup + Foundational → foundation ready.
2. US1 → quickstart walk → merge.
3. US2 → vector schema + canonicalization check → merge.
4. US3 → Lean + QuickCheck + parity script → merge.
5. Polish → final `mkdocs build --strict` + disclaimer updates.

Each increment is bisect-safe: the Aiken skeleton exists from Phase 1,
the parity matrix exists from Phase 2, and no commit leaves the DSL
in a non-compiling state.

### Stub policy (bisect-safety)

Per constitution workflow and Haskell skill:

- T007's empty `Intention` GADT and T040's `sorry`-bodied Lean
  theorems are *deliberate stubs*. They are replaced later in the
  same phase (T018, backend PRs). Annotate with
  `-- NOTE: stub for bisect-safety, filled by T018` / `-- sorry:
  discharged by the first backend PR` so reviewers can tell they are
  intentional.
- No stubs may survive past Phase 6.

---

## Notes

- [P] tasks = different files, no in-flight dependencies.
- Every task has an exact file path.
- Constitution check is re-verified in Phase 6 via `just CI` + manual
  spec walk.
- Citations (Merkle, Tessaro-Zhu, GMR) appear in three places: spec,
  Lean file header, QuickCheck module header. Redundant by design
  (principle 7a).
- All task subjects use the conventional-commits vocabulary the
  constitution names: `feat:` for new DSL surface, `docs:` for
  prose, `parity:` for matrix rows, `port:` is reserved for backend
  PRs (not used here).
- No `cardano-api` usage — constitution §Stack and user memory
  `no_cardano_api` both forbid it. Chain I/O is out of scope
  regardless.
