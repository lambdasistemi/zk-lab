{
  description = "zk-lab — intention-driven ZK DSL for Cardano";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # GHC 9.10 series. nixpkgs-unstable exposes ghc910 as the attribute
        # for the 9.10.x major series.
        haskell = pkgs.haskell.packages.ghc910;

        # Bundle the shared vectors store into the offchain source tree
        # so the test-suite (ZK.Vectors.SetMembershipSpec) can reach it
        # from cabal's working directory inside the nix sandbox. The
        # loader defaults to the relative path "vectors/set-membership",
        # which resolves against that bundled layout.
        offchainSrcWithVectors =
          pkgs.runCommand "zk-lab-offchain-with-vectors" { } ''
            mkdir -p $out
            cp -r ${./offchain}/. $out/
            cp -r ${./vectors} $out/vectors
          '';

        offchain = haskell.callCabal2nix "zk-lab" offchainSrcWithVectors { };

        checks = import ./nix/checks.nix { inherit pkgs haskell offchain; };

        apps = import ./nix/apps.nix { inherit pkgs checks; };

        devTools = [
          haskell.ghc
          haskell.cabal-install
          haskell.fourmolu
          haskell.hlint
          haskell.cabal-fmt
          pkgs.just
          pkgs.nixfmt-classic
          pkgs.shellcheck
        ];
      in {
        devShells.default = pkgs.mkShell {
          name = "zk-lab-dev";
          buildInputs = devTools;
        };

        packages.offchain = offchain;
        packages.default = offchain;

        inherit checks apps;
      });
}
