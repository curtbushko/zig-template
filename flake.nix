{
  description = "Zig project template with Nix flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Zig overlay for managing Zig versions
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For flake-utils to support multiple systems
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, zig-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        # Pin to Zig 0.16.0
        zigPkg = zig-overlay.packages.${system}."0.16.0";

        # Make wrapper to allow 'make' command to call task
        make-wrapper = pkgs.writeShellScriptBin "make" ''
          exec ${pkgs.go-task}/bin/task "$@"
        '';

      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Zig compiler (pinned version)
            zigPkg

            # Task runner (used as make replacement)
            go-task
            make-wrapper

            # Development tools
            git

            # Optional: Language servers and formatters
            zls  # Zig Language Server
          ];

          shellHook = ''
            # Auto-pull if on main branch
            if [ "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" = "main" ]; then
              echo "On main branch, pulling latest changes..."
              git pull --quiet || true
            fi

            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "  Zig Template Development Environment"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "  Zig:     $(zig version)"
            echo "  Task:    $(task --version)"
            echo ""
            echo "  Run 'task' to see available commands"
            echo "  Run 'task build' to build the project"
            echo "  Run 'task test' to run tests"
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          '';
        };

        # Optional: Package the project
        packages.default = pkgs.stdenv.mkDerivation {
          name = "zig-template";
          src = ./.;

          nativeBuildInputs = [ zigPkg ];

          buildPhase = ''
            zig build -Doptimize=ReleaseSafe
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp zig-out/bin/zig-template $out/bin/
          '';
        };
      }
    );
}
