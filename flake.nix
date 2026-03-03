{
  description = "Template project for GHC WebAssembly backend with Reflex FRP";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    ghc-wasm-meta.url = "gitlab:haskell-wasm/ghc-wasm-meta?host=gitlab.haskell.org";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      perSystem = { pkgs, system, ... }: let
        # Use GHC 9.12 flavour — reflex ecosystem is tested against this version.
        ghc-wasm = inputs.ghc-wasm-meta.packages.${system}.all_9_12;
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            ghc-wasm

            # Build tool
            pkgs.just

            # Local dev server with live-reload for testing in browser
            pkgs.live-server
          ];
        };
      };
    };
}
