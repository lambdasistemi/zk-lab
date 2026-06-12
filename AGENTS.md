# Repository Agent Guide

## What this repo is

zk-lab is an experimental laboratory for an **intention-driven
zero-knowledge DSL** targeting Plutus. A user expresses a privacy
statement once (e.g. "this private value is a member of this committed
set") and the lab realizes it across backends — Groth16, BBS+, Halo2 —
with feature parity as a design goal. The DSL is the product; backends
are plumbing. Correctness is pinned outside any backend by a shared
test-vector store and a dual property specification (the same
properties stated in Lean and in QuickCheck, kept 1:1 by CI). It is
experimental — toy trusted setups only, never for mainnet. Today only
the first primitive, **set membership**, exists, and only as a DSL-only
slice: no Groth16/BBS+/Halo2 backend has landed.

## How to work here

Everything runs through the Nix flake and the `justfile`. Enter the dev
shell first; `just` with no argument lists all recipes.

- Dev shell: `nix develop` (GHC 9.10, `cabal`, `fourmolu`, `hlint`,
  `cabal-fmt`, `just`).
- Build the DSL: `just build-dsl` (`cabal build all -O0`).
- Test the DSL: `just test-dsl` (hspec + QuickCheck — properties and
  the vector loader).
- Vector store gate: `just check-vectors` (JSON-schema validation +
  canonicalization cross-check).
- Property-parity gate: `just check-property-parity` (Lean ↔ QuickCheck
  1:1, SC-003).
- Lean spec: `just build-lean` (`lake build`). Aiken skeleton:
  `just build-aiken-skeleton` (`aiken check`).
- Docs: `just docs-strict` (`mkdocs build --strict`).
- Format / lint: `just format`, `just hlint`.
- Full CI mirror: `just CI`. The Lean/Aiken/JSON-schema toolchains are
  not in the dev shell — those recipes shell out to sandboxed flake
  apps (`nix run .#<app>`), so no extra install is needed.

CI is `.github/workflows/ci.yml` (the flake checks: `offchain`,
`format`, `hlint`, `lean`, `aiken-skeleton`, `vectors`,
`property-parity`, `docs-disclaimers`, `docs-strict`). Docs deploy via
`.github/workflows/deploy-docs.yml`.

Scope discipline this repo enforces: the DSL surface must stay
backend-free; every primitive ships a Lean theorem + a QuickCheck
property + a shared vector file; no production-readiness claims in
`docs/**` (FR-011, gated in CI); every borrowed formulation carries a
citation (constitution principle 7a).

## Skills

Activatable procedures live under `skills/`. Load the one whose
description matches your task:

- `skills/zk-lab-guide/` — repository map, the exact build/test/run
  commands, how to navigate the code, how to use the DSL, and where the
  answers to common questions about this repo live.
