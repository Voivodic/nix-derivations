{
    description = "Voivodic's custom packages for nix";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils, ... }:
        let
            localOverlay = final: prev: {
                pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
                    (python-final: python-prev: {
                        # Cosmo
                        pyexshalos = python-final.callPackage ./pkgs/cosmo/pyexshalos {};
                        class-pt = python-final.callPackage ./pkgs/cosmo/class-pt {};

                        # NN
                        e3nn-jax = python-final.callPackage ./pkgs/nn/e3nn-jax { 
                            cudaSupport = prev.config.cudaSupport or false; 
                        };
                        diffrax = python-final.callPackage ./pkgs/nn/diffrax { 
                            cudaSupport = prev.config.cudaSupport or false; 
                        };

                        # Utils
                        getdist = python-final.callPackage ./pkgs/utils/getdist {};
                    })
                ];
            };
        in
        flake-utils.lib.eachDefaultSystem (system:
            let
                makePkgs = cudaSupport: import nixpkgs { 
                    inherit system;
                    config.allowUnfree = true;
                    config.cudaSupport = cudaSupport;
                    overlays = [ localOverlay ];
                };

                pkgs = makePkgs false;
                pkgs-cuda = makePkgs true;

                # Helper to create a clean, flat package set
                extractPackages = p: {
                    # Top-level access (defaults to Python 3.13)
                    inherit (p.python313Packages) pyexshalos class-pt e3nn-jax diffrax getdist;

                    # Versioned access
                    python312 = {
                        inherit (p.python312Packages) pyexshalos class-pt e3nn-jax diffrax getdist;
                    };
                    python313 = {
                        inherit (p.python313Packages) pyexshalos class-pt e3nn-jax diffrax getdist;
                    };
                };
            in {
                # Standard flake packages
                packages = (extractPackages pkgs) // {
                    cuda = extractPackages pkgs-cuda;
                };

                # Exposing the full pkgs with our overlay as legacyPackages
                # This allows usage like: gitpkgs.legacyPackages.${system}.python313.diffrax
                legacyPackages = pkgs;
                legacyPackagesCUDA = pkgs-cuda;
            }
        ) // {
            overlays.default = localOverlay;
        };
}
