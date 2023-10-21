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
              rev = "8409e7aaa617ac7ea5f74d2601cb18247495237e";
              sha256 = "sha256-8RzbAO708b+/NFOeO9ppeNVKvSC7kjay9BeNT3tpNLY=";
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
