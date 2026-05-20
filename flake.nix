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

                # Helper to extract our packages from a pkgs instance
                extractPackages = p: {
                    pyexshalos = p.python313Packages.pyexshalos;
                    class-pt = p.python313Packages.class-pt;
                    e3nn-jax = p.python313Packages.e3nn-jax;
                    diffrax = p.python313Packages.diffrax;
                    getdist = p.python313Packages.getdist;

                    # Expose multiple python versions if needed
                    python312 = {
                        pyexshalos = p.python312Packages.pyexshalos;
                        class-pt = p.python312Packages.class-pt;
                        e3nn-jax = p.python312Packages.e3nn-jax;
                        diffrax = p.python312Packages.diffrax;
                        getdist = p.python312Packages.getdist;
                    };
                    python313 = {
                        pyexshalos = p.python313Packages.pyexshalos;
                        class-pt = p.python313Packages.class-pt;
                        e3nn-jax = p.python313Packages.e3nn-jax;
                        diffrax = p.python313Packages.diffrax;
                        getdist = p.python313Packages.getdist;
                    };
                };
            in {
                packages = (extractPackages pkgs) // {
                    cuda = extractPackages pkgs-cuda;
                };
            }
        ) // {
            overlays.default = localOverlay;
        };
}
