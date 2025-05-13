{ localInputs }:
{
  config,
  lib,
  flake-parts-lib,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkPerSystemOption;
in {
  imports = [
    localInputs.git-hooks-nix.flakeModule
  ];

  options.perSystem = mkPerSystemOption (
    {
      config,
      pkgs,
      ...
    }:
    {
      options.tmg-devops = {
        packages = mkOption {
          type = types.listOf types.package;
          default = [];
          description = "A list of packages to add to the devshell";
        };

        shellHook = mkOption {
          type = types.str;
          default = "";
          description = "Bash statement(s) executed when entering the shell";
        };
      };

      config = {
        devShells.default = pkgs.mkShell {
          name = "TmgDevOps";
          shellHook = ''
              ${config.pre-commit.installationScript}
              ${config.tmg-devops.shellHook}
          '';
          packages = config.tmg-devops.packages;
          inputsFrom = [ config.pre-commit.devShell ];
        };

        pre-commit.settings.hooks = {
          markdownlint.enable = true;
          check-merge-conflicts.enable = true;
          end-of-file-fixer.enable = true;
          trim-trailing-whitespace.enable = true;
        };
      };
    }
  );
}
