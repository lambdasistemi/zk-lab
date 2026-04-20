{ pkgs, checks }:
let
  runnable = {
    inherit (checks) format hlint;
  };
in
builtins.mapAttrs
  (_: check: {
    type = "app";
    program = pkgs.lib.getExe check;
  })
  runnable
