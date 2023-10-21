{
  description = "Flake utils demo";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.default = pkgs.mkShell.override {
        stdenv = pkgs.emscriptenStdenv;
      } {
        nativeBuildInputs = with pkgs; [
          perlPackages.DigestSHA3 unzip gnumake
        ];
      };
    });
}
