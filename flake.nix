{
    description = "Voivodic's custom packages for nix";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils, ... }:
        flake-utils.lib.eachDefaultSystem (system:
        let
            pkgs = import nixpkgs { inherit system; };
        
            # Package definitions
            packages = {
                # Cosmo
                pyexshalos = pkgs.python3Packages.callPackage ./pkgs/cosmo/pyexshalos {};

                # NN
                e3nn-jax = pkgs.python3Packages.callPackage ./pkgs/nn/e3nn-jax {};
                diffrax = pkgs.python3Packages.callPackage ./pkgs/nn/diffrax {};
            };
        in {
            packages = packages;
           
            # Expose as overlay
            overlays.default = final: prev: packages;
        }
    );
}
