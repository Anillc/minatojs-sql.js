# new clouse-compiler doesn't support /** global */ in api.js
{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/e19f25b587f15871d26442cfa1abe4418a815d7d.tar.gz") {} }:

pkgs.mkShell.override {
    stdenv = pkgs.emscriptenStdenv;
} {
    name = "sql.js";
    nativeBuildInputs = with pkgs; [
        perlPackages.DigestSHA3 unzip gnumake
    ];
}
