{ pkgs, haskell, offchain }:
let
  offchainSrc = ../offchain;
  leanSrc = ../lean;
  aikenSrc = ../onchain/verifiers/set_membership;
  vectorsSrc = ../vectors;
  docsSrc = ../.;
in {
  # Haskell library check.
  offchain = offchain;

  # Fourmolu + cabal-fmt formatting gate.
  format = pkgs.writeShellApplication {
    name = "zk-lab-format-check";
    runtimeInputs = [ haskell.fourmolu haskell.cabal-fmt ];
    excludeShellChecks = [ "SC2046" "SC2086" ];
    text = ''
      cd ${offchainSrc}
      fourmolu -m check src test
      cabal-fmt -c ./*.cabal
    '';
  };

  # hlint gate.
  hlint = pkgs.writeShellApplication {
    name = "zk-lab-hlint";
    runtimeInputs = [ haskell.hlint ];
    excludeShellChecks = [ "SC2046" "SC2086" ];
    text = ''
      cd ${offchainSrc}
      hlint src test
    '';
  };

  # Lean build gate. Builds the offline Phase 1 placeholder module.
  # Mathlib pin arrives with Phase 3 US3 via a proper flake input.
  lean = pkgs.writeShellApplication {
    name = "zk-lab-lean-build";
    runtimeInputs = [ pkgs.lean4 ];
    excludeShellChecks = [ "SC2046" "SC2086" ];
    text = ''
      work=$(mktemp -d)
      cp -r ${leanSrc}/. "$work"/
      cd "$work"
      lake build
    '';
  };

  # Aiken skeleton gate — checks the module type-checks. Stdlib pin
  # arrives with Phase 3 once a real verifier lands.
  aiken-skeleton = pkgs.writeShellApplication {
    name = "zk-lab-aiken-check";
    runtimeInputs = [ pkgs.aiken ];
    excludeShellChecks = [ "SC2046" "SC2086" ];
    text = ''
      work=$(mktemp -d)
      cp -r ${aikenSrc}/. "$work"/
      cd "$work"
      aiken check
    '';
  };

  # Vector JSON gate. Validates every positive/*.json and
  # tampering/*.json under vectors/set-membership/ against
  # schema.json. The companion canonicalization check —
  # canonicalSet / canonicalTag agree with ZK.Canonicalize on the raw
  # set input — lives in the offchain check's unit-tests (see
  # ZK.Vectors.SetMembershipSpec, T025). The two together make the
  # vector store self-describing (contracts/vectors.md).
  vectors = pkgs.writeShellApplication {
    name = "zk-lab-vectors-check";
    runtimeInputs = [ pkgs.check-jsonschema ];
    excludeShellChecks = [ "SC2046" "SC2086" ];
    text = ''
      cd ${vectorsSrc}
      shopt -s nullglob
      positives=(set-membership/positive/*.json)
      tamperings=(set-membership/tampering/*.json)
      if [[ ''${#positives[@]} -eq 0 ]]; then
        echo "vectors: no positive cases found under set-membership/positive/" >&2
        exit 1
      fi
      check-jsonschema \
        --schemafile set-membership/schema.json \
        "''${positives[@]}" "''${tamperings[@]}"
      count=$((''${#positives[@]} + ''${#tamperings[@]}))
      echo "vectors: $count cases validated against schema.json"
    '';
  };

  # Property-parity gate (SC-003): every Lean theorem in the named
  # parity section of lean/ZKLab/SetMembership.lean must have a
  # QuickCheck counterpart in offchain/src/ZK/DSL/Properties/
  # SetMembership.hs, matching the mapping table in
  # specs/001-set-membership/contracts/properties.md.
  property-parity = pkgs.writeShellApplication {
    name = "zk-lab-property-parity";
    runtimeInputs = [ pkgs.bash pkgs.gawk pkgs.coreutils pkgs.gnugrep ];
    excludeShellChecks = [ "SC2046" "SC2086" ];
    text = ''
      work=$(mktemp -d)
      mkdir -p "$work/offchain/scripts" "$work/lean/ZKLab" \
          "$work/offchain/src/ZK/DSL/Properties" "$work/specs"
      cp ${offchainSrc}/scripts/check-property-parity.sh \
          "$work/offchain/scripts/"
      cp ${offchainSrc}/src/ZK/DSL/Properties/SetMembership.hs \
          "$work/offchain/src/ZK/DSL/Properties/"
      cp ${leanSrc}/ZKLab/SetMembership.lean "$work/lean/ZKLab/"
      touch "$work/specs/.gitkeep"
      export ZK_LAB_ROOT="$work"
      bash "$work/offchain/scripts/check-property-parity.sh"
    '';
  };

  # Docs disclaimer gate (FR-011): block production-readiness
  # claims in docs/**/*.md.
  docs-disclaimers = pkgs.writeShellApplication {
    name = "zk-lab-docs-disclaimers";
    runtimeInputs = [ pkgs.bash pkgs.gnugrep pkgs.coreutils ];
    excludeShellChecks = [ "SC2046" "SC2086" ];
    text = ''
      work=$(mktemp -d)
      mkdir -p "$work/offchain/scripts"
      cp ${offchainSrc}/scripts/check-docs-disclaimers.sh \
          "$work/offchain/scripts/"
      cp -r ${docsSrc}/docs "$work/docs"
      export ZK_LAB_ROOT="$work"
      bash "$work/offchain/scripts/check-docs-disclaimers.sh"
    '';
  };

  # mkdocs --strict gate for every docs/ page.
  docs-strict = let
    mkdocsEnv = pkgs.python3.withPackages
      (ps: [ ps.mkdocs ps.mkdocs-material ps.pymdown-extensions ]);
  in pkgs.writeShellApplication {
    name = "zk-lab-docs-strict";
    runtimeInputs = [ mkdocsEnv ];
    excludeShellChecks = [ "SC2046" "SC2086" ];
    text = ''
      work=$(mktemp -d)
      cp -r ${docsSrc}/. "$work"/
      cd "$work"
      mkdocs build --strict --site-dir "$work/_site"
    '';
  };

  # mkdocs build emitting ./site in the caller's cwd. Consumed by
  # deploy-docs.yml (surge preview + gh-deploy).
  docs-build = let
    mkdocsEnv = pkgs.python3.withPackages
      (ps: [ ps.mkdocs ps.mkdocs-material ps.pymdown-extensions ]);
  in pkgs.writeShellApplication {
    name = "zk-lab-docs-build";
    runtimeInputs = [ mkdocsEnv ];
    excludeShellChecks = [ "SC2046" "SC2086" ];
    text = ''
      mkdocs build --strict --site-dir ./site
    '';
  };

  # mkdocs gh-deploy — publishes the built site to the gh-pages
  # branch. Not a verification check; exposed as an app via apps.nix.
  docs-deploy = let
    mkdocsEnv = pkgs.python3.withPackages
      (ps: [ ps.mkdocs ps.mkdocs-material ps.pymdown-extensions ]);
  in pkgs.writeShellApplication {
    name = "zk-lab-docs-deploy";
    runtimeInputs = [ mkdocsEnv pkgs.git ];
    excludeShellChecks = [ "SC2046" "SC2086" ];
    text = ''
      mkdocs gh-deploy --force
    '';
  };
}
