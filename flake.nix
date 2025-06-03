{
    description = "Voivodic's custom packages for nix";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils, ... }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = import nixpkgs { 
                    inherit system;
                    config.allowUnfree = true;
                };

                # Package definitions
                packages = {
                    python312 = {
                        # Cosmo
                        pyexshalos = pkgs.python312Packages.callPackage ./pkgs/cosmo/pyexshalos {};
                        class-pt = pkgs.python312Packages.callPackage ./pkgs/cosmo/class-pt {};

                        # NN
                        e3nn-jax = pkgs.python312Packages.callPackage ./pkgs/nn/e3nn-jax {};
                        diffrax = pkgs.python312Packages.callPackage ./pkgs/nn/diffrax {};

                        # Utils
                        getdist = pkgs.python312Packages.callPackage ./pkgs/utils/getdist {};
                    };
                    python313 = {
                        # Cosmo
                        pyexshalos = pkgs.python313Packages.callPackage ./pkgs/cosmo/pyexshalos {};
                        class-pt = pkgs.python313Packages.callPackage ./pkgs/cosmo/class-pt {};

                        # NN
                        e3nn-jax = pkgs.python313Packages.callPackage ./pkgs/nn/e3nn-jax {};
                        diffrax = pkgs.python313Packages.callPackage ./pkgs/nn/diffrax {};

                        # Utils
                        getdist = pkgs.python313Packages.callPackage ./pkgs/utils/getdist {};
                    };

                };
            in {
                packages = packages;

                # Expose as overlay
                overlays.default = final: prev: packages;
            }
        );
}
