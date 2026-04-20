# shellcheck shell=bash

set unstable := true

default:
    @just --list

# Format Haskell sources and *.cabal files in place (dev-only).
format:
    #!/usr/bin/env bash
    set -euo pipefail
    for _ in 1 2 3; do
        fourmolu -i offchain/src offchain/test 2>/dev/null || true
    done
    cabal-fmt -i offchain/*.cabal
    nixfmt flake.nix nix/*.nix

# CI check recipes — thin wrappers over the sandboxed flake apps.
format-check:
    nix run --quiet .#format

hlint:
    nix run --quiet .#hlint

build-lean:
    nix run --quiet .#lean

build-aiken-skeleton:
    nix run --quiet .#aiken-skeleton

# T035: schema validation (nix check `vectors`, via check-jsonschema)
# + canonicalization check (inside the offchain unit-tests,
# ZK.Vectors.SetMembershipSpec T025).
check-vectors:
    #!/usr/bin/env bash
    set -euo pipefail
    nix run --quiet .#vectors
    nix build --quiet .#checks.x86_64-linux.offchain

docs-strict:
    nix run --quiet .#docs-strict

# Local cabal recipes (dev-only, require `nix develop`).
build-dsl:
    cabal build all -O0

test-dsl:
    cabal test all -O0 --test-show-details=direct

# Local CI sequence — mirrors .github/workflows/ci.yml exactly.
CI:
    #!/usr/bin/env bash
    set -euo pipefail
    nix build --quiet \
        .#checks.x86_64-linux.offchain \
        .#checks.x86_64-linux.format \
        .#checks.x86_64-linux.hlint \
        .#checks.x86_64-linux.lean \
        .#checks.x86_64-linux.aiken-skeleton \
        .#checks.x86_64-linux.vectors \
        .#checks.x86_64-linux.docs-strict
    nix run --quiet .#format
    nix run --quiet .#hlint
    nix run --quiet .#lean
    nix run --quiet .#aiken-skeleton
    nix run --quiet .#vectors
    nix run --quiet .#docs-strict
