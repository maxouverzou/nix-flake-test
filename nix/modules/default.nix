{
  config,
  inputs,
  flake-parts-lib,
  ...
}: let
  inherit (flake-parts-lib) importApply;
in {
  flake.flakeModules = {
    default = config.flake.flakeModules.base;

    base =  importApply ./base.nix {localInputs = inputs;};
    python = importApply ./python.nix {localInputs = inputs;};
  };
}
