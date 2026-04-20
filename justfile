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

# Run the same checks CI runs, via nix apps.
format-check:
    nix run --quiet .#format

hlint:
    nix run --quiet .#hlint

# Build the DSL library via cabal (inside nix develop).
build-dsl:
    cabal build all -O0

# Run the DSL test suite. Empty until Phase 3 US1 adds tests.
test-dsl:
    cabal test all -O0 --test-show-details=direct

# Local CI sequence — mirrors .github/workflows/ci.yml exactly.
CI:
    #!/usr/bin/env bash
    set -euo pipefail
    nix build --quiet \
        .#checks.x86_64-linux.offchain \
        .#checks.x86_64-linux.format \
        .#checks.x86_64-linux.hlint
    nix run --quiet .#format
    nix run --quiet .#hlint
