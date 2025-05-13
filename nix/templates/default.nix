{config, ...}: {
  flake.templates = {
    flake-parts = {
      path = ./flake-parts.nix;
      description = "Basic example using flake-parts";
    };
    default = config.flake.templates.flake-parts;
  };
}
