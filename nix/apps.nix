{ pkgs, checks }:
let
  runnable = {
    inherit (checks)
      format hlint lean aiken-skeleton vectors property-parity docs-disclaimers
      docs-strict docs-build docs-deploy;
  };
in builtins.mapAttrs (_: check: {
  type = "app";
  program = pkgs.lib.getExe check;
}) runnable
