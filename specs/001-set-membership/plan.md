# Implementation Plan: Set Membership

**Branch**: `001-set-membership` | **Date**: 2026-04-19 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-set-membership/spec.md`

## Summary

Ship the first DSL primitive — set membership — as a DSL-only slice: a
Haskell-embedded intention type, a canonical JSON vector store under
`vectors/set-membership/`, a Lean 4 property module stating
completeness/soundness/zero-knowledge, a matching QuickCheck module,
and an empty Aiken verifier directory that downstream PRs fill in.

No backend cryptography lands here. The value of this slice is
infrastructure: once the intention, vectors, and properties exist, a
backend PR is reviewable in under an hour (SC-005) because the contract
is already written.

Narrative order is enforced by the directory layout:
`docs/dsl/primitives/set-membership/` (intention) →
`vectors/set-membership/` + `lean/ZKLab/SetMembership.lean` (semantics)
→ `offchain/src/ZK/DSL/...` + `onchain/verifiers/set_membership/`
(implementation surface, empty until backends land).

## Technical Context

**Language/Version**: Haskell GHC 9.10.1 (DSL + QuickCheck); Lean 4 +
Mathlib4 (formal properties); Aiken 1.1+ (Plutus verifier skeleton —
empty stubs only this slice).
**Primary Dependencies**: `base`, `bytestring`, `aeson` (vector JSON),
`QuickCheck`, `hspec` (off-chain test harness); `Mathlib.Probability`
(Lean property module). No Rust, no FFI, no backend crates *in this
slice*. Constitution principle 5 (FFI is the cryptography boundary)
applies to backend PRs; this DSL-only slice contains no cryptography,
so no FFI surface exists to bound yet — the boundary is established
when the first backend lands.
**Storage**: On-disk JSON under `vectors/set-membership/` (format-
agnostic, format-stable). No databases, no generated artifacts in git.
**Testing**: `hspec` drives QuickCheck properties; vectors loaded via
`aeson`. Lean is verified by `lake build` — no runtime harness, the
proof check *is* the test.
**Target Platform**: Linux (NixOS self-hosted CI runner); macOS via
Nix flake for local dev. The DSL is pure Haskell — no platform-specific
code.
**Project Type**: Multi-root lab — `offchain/` (Haskell), `lean/`
(formal), `vectors/` (shared test data), `onchain/` (Aiken), `docs/`
(MkDocs). Each root has its own build driver but all ship in one PR
train.
**Performance Goals**: Not applicable to this slice. Vector loading
and QuickCheck runs are development-time; no runtime SLO. Bench
numbers (prover time, Plutus budget) arrive with the first backend.
**Constraints**: `mkdocs build --strict` must stay green every commit
(bisect-safety). No backend-local fixtures may exist for this primitive
(FR-005). No production-readiness language anywhere (FR-011).
**Scale/Scope**: One primitive, three target backends (Groth16, BBS+,
Halo2) rendered as parity-matrix rows (all ❌ at this spec's merge).
Expected LOC: ~150 Haskell (DSL + QC), ~80 Lean, ~20 vector JSON, ~30
Aiken skeleton (module declaration + `TODO` comments).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| # | Principle | Check | Status |
|---|-----------|-------|--------|
| 1 | Intention, not circuits | DSL exposes `member :: Value -> SetCommitment s -> Intention SetMembership`. No circuit/curve/R1CS terms in user-visible API. | PASS |
| 2 | Feature parity as a design target | Parity matrix row added with all three backends at ❌. Matrix renders in docs (SC-004). | PASS |
| 3 | Plutus is the on-chain target | Aiken skeleton at `onchain/verifiers/set_membership/` is named and anchored (FR-010). | PASS |
| 4 | Import, don't reinvent | No backend code here; import policy applies to backend PRs. Citations for Merkle/BBS+/GMR 1989 already in spec. | PASS |
| 5 | FFI is the cryptography boundary | No cryptography in this slice, so no FFI surface yet to bound. The boundary is established and gated when the first backend PR lands (documented in plan.md §Technical Context). | PASS (deferred) |
| 6 | Correctness before performance | QuickCheck properties include negative-witness cases; vector store catalogues tampering cases with expected `reject` verdicts. | PASS |
| 6a | Shared test vectors | `vectors/set-membership/` is the sole fixture source (FR-004, FR-005). | PASS |
| 6b | Properties, dual-specified | `lean/ZKLab/SetMembership.lean` + `offchain/src/ZK/DSL/Properties/SetMembership.hs` in same PR (FR-006, FR-007, SC-003). | PASS |
| 7 | Culture is first-class | Citations in spec link to semantic graph nodes for Merkle, BBS+, GMR. | PASS |
| 7a | Steal, always cite | Three citations with DOIs already in spec; Lean and QuickCheck files will carry file-level citation headers. | PASS |
| 8 | Reproducible builds | Haskell via haskell.nix, Lean via lake, Aiken via Nix. All driven from `flake.nix`. | PASS |
| 9 | Honest documentation | `docs/dsl/primitives/set-membership.md` logs the intention and the known gaps (all three backends ❌ at merge). | PASS |
| 10 | No production recommendations | FR-011 mandates "experimental, toy trusted setups only" in every touched README. | PASS |

**Result**: No violations. No entries in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/001-set-membership/
├── plan.md                  # This file
├── research.md              # Phase 0 output
├── data-model.md            # Phase 1 output
├── quickstart.md            # Phase 1 output
├── contracts/
│   ├── intention.md         # DSL surface
│   ├── properties.md        # Lean ↔ QuickCheck mapping
│   └── vectors.md           # JSON schema for the shared store
├── checklists/
│   └── requirements.md      # Spec quality checklist (already green)
└── tasks.md                 # /speckit.tasks output (not this command)
```

### Source Code (repository root)

```text
offchain/
├── src/ZK/DSL/
│   ├── Intention.hs              # GADT: Intention a
│   ├── SetMembership.hs          # `member`, Value, SetCommitment types
│   └── Properties/
│       └── SetMembership.hs      # QuickCheck generators + properties
├── src/ZK/Vectors/
│   └── SetMembership.hs          # JSON loader for vectors/set-membership/
├── test/
│   └── ZK/DSL/SetMembershipSpec.hs
└── zk-lab.cabal

lean/
├── ZKLab/
│   └── SetMembership.lean        # Formal properties: completeness,
│                                 # soundness, zero-knowledge
├── lakefile.lean
└── lean-toolchain

vectors/
└── set-membership/
    ├── schema.json               # JSON Schema document
    ├── positive/
    │   ├── singleton.json
    │   ├── small-set.json
    │   └── canonical-dedup.json
    └── tampering/
        ├── non-member.json
        ├── wrong-commitment.json
        ├── flipped-proof-bit.json
        └── replay-across-sets.json

onchain/
└── verifiers/
    └── set_membership/
        ├── aiken.toml            # Aiken project descriptor
        ├── lib/
        │   └── set_membership.ak # Module with `TODO` stub only
        └── README.md             # "experimental, toy setups only"

docs/
└── dsl/
    ├── primitives/
    │   └── set-membership.md     # Intention, semantics, implementation
    │                             # (implementation = "see parity matrix")
    └── parity-matrix.md          # Row added for set-membership
```

**Structure Decision**: Multi-root lab. The DSL (`offchain/`) is the
product; other roots are peers, not children. This mirrors the
constitution's stack section (DSL, backends, FFI, onchain, build) and
keeps each root independently buildable. The Nix flake exposes one
check per root; CI's build gate covers all of them.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No violations. Table intentionally empty.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| — | — | — |
