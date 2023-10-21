{
  description = "Flake utils demo";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [(self: super: {
          emscripten = super.emscripten.overrideAttrs (old: {
            src = super.fetchFromGitHub {
              owner = "Anillc";
              repo = "emscripten";
              rev = "9a4512d2620402cd47af63bfc114e6088d5eae7c";
              sha256 = "sha256-zgqN4JPoPTOpZdXpkE6BsPjYPJx3Nid/VcfMSfNv8A4=";
            };
          });
        })];
      };
    in {
      devShells.default = pkgs.mkShell.override {
        stdenv = pkgs.emscriptenStdenv;
      } {
        nativeBuildInputs = with pkgs; [
          perlPackages.DigestSHA3 unzip gnumake
        ];
        shellHook = ''
          export EM_CACHE=$PWD/.emscriptencache
        '';
      };
    });
}
