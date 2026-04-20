{ pkgs, haskell, offchain }:
let
  offchainSrc = ../offchain;
in
{
  offchain = offchain;

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

  hlint = pkgs.writeShellApplication {
    name = "zk-lab-hlint";
    runtimeInputs = [ haskell.hlint ];
    excludeShellChecks = [ "SC2046" "SC2086" ];
    text = ''
      cd ${offchainSrc}
      hlint src test
    '';
  };
}
