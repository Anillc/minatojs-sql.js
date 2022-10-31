{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
    name = "sql.js";
    nativeBuildInputs = with pkgs; [
        perlPackages.DigestSHA3 emscripten unzip gnumake
    ];
}