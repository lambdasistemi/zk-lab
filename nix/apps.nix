{ pkgs, checks }:
let
  runnable = {
    inherit (checks)
      format hlint lean aiken-skeleton vectors docs-strict docs-build
      docs-deploy;
  };
in builtins.mapAttrs (_: check: {
  type = "app";
  program = pkgs.lib.getExe check;
}) runnable
