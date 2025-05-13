{ localInputs }:
{
  config,
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (flake-parts-lib) mkPerSystemOption;
in
{
  imports = [
    localInputs.git-hooks-nix.flakeModule
  ];

  options.perSystem = mkPerSystemOption (
    {
      config,
      pkgs,
      ...
    }:
    let
      formatToml = pkgs.formats.toml { };

      ruff-config = formatToml.generate  "ruff.toml" {
        # Exclude a variety of commonly ignored directories.
        exclude = [
          ".bzr"
          ".direnv"
          ".eggs"
          ".git"
          ".git-rewrite"
          ".hg"
          ".ipynb_checkpoints"
          ".mypy_cache"
          ".nox"
          ".pants.d"
          ".pyenv"
          ".pytest_cache"
          ".pytype"
          ".ruff_cache"
          ".svn"
          ".tox"
          ".venv"
          ".vscode"
          "__pypackages__"
          "_build"
          "buck-out"
          "build"
          "dist"
          "node_modules"
          "site-packages"
          "venv"
        ];
        # Same as Black.
        line-length = 88;
        indent-width = 4;
        # Assume Python 3.9
        target-version = "py39";

        lint = {
          # "B950" is not supported yet , see https://github.com/astral-sh/ruff/issues/17439
          select = [
            "C"
            "E"
            "F"
            "W"
            "B"
          ];
          ignore = [
            "E203"
            "E501"
          ];

          # Allow fix for all enabled rules (when `--fix`) is provided.
          fixable = [ "ALL" ];
          unfixable = [ ];

          # Allow unused variables when underscore-prefixed.
          dummy-variable-rgx = "^(_+|(_+[a-zA-Z0-9_]*[a-zA-Z0-9]+?))$";
        };
        format = {
          # Like Black, use double quotes for strings.
          quote-style = "double";

          # Like Black, indent with spaces, rather than tabs.
          indent-style = "space";

          # Like Black, respect magic trailing commas.
          skip-magic-trailing-comma = false;

          # Like Black, automatically detect the appropriate line ending.
          line-ending = "auto";
        };
        isort = {
          force-single-line = true;
          single-line-exclusions = [ "typing" ];
        };
        flake8-bandit = { };
      };
    in
    {
      pre-commit.settings.hooks = {
        ruff = {
          enable = true;
          entry = "${config.pre-commit.settings.hooks.ruff.package}/bin/ruff check --fix --config ${ruff-config}";
          before = [ "ruff-format" ];
        };
        ruff-format = {
          enable = true;
          entry = "${config.pre-commit.settings.hooks.ruff-format.package}/bin/ruff format --config ${ruff-config}";
        };
        pyright = {
          enable = true;
          before = [ "ruff" "ruff-format" ];
        };
        xenon = {
          name = "xenon";
          enable = true;
          entry = "${pkgs.xenon}/bin/xenon --max-absolute A --max-modules A --max-average A";
          before = [ "ruff" "ruff-format" ];
          types = [ "python" ];
        };
      };

      pre-commit.settings.enabledPackages = with pkgs; [
        (pkgs.python3.withPackages (python-pkgs: [
          python-pkgs.pip
          python-pkgs.pip-tools
          python-pkgs.virtualenv
        ]))
      ];

      tmg-devops = {
        shellHook = ''
            [ -f .venv/pyvenv.cfg ] || python -m venv .venv
            source .venv/bin/activate

            test -f requirements.txt && pip install -r requirements.txt
            test -f requirements-dev.txt && pip install -r requirements-dev.txt
        '';
      };
    }
  );
}
