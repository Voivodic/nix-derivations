{
    description = "Test of the derivations taken directly from github";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        gitpkgs.url = "path:../../";
        gitpkgs.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = { self, nixpkgs, gitpkgs, ... }: 
    let
        # Define the system
        system = "x86_64-linux";
        pkgs = import nixpkgs { 
            inherit system;
            config.allowUnfree = true;
            config.cudaSupport = true;
            overlays = [ gitpkgs.overlays.default ];
        };
    in { 
        devShells.${system} = let
            mkShell = python: pkgName: pkgs.mkShell {
                buildInputs = [
                    (python.withPackages (ps: [ ps.${pkgName} ]))
                ];
            };
        in {
            pyexshalos = mkShell pkgs.python313 "pyexshalos";
            class-pt = mkShell pkgs.python313 "class-pt";
            getdist = mkShell pkgs.python313 "getdist";
            e3nn-jax = mkShell pkgs.python313 "e3nn-jax";
            diffrax = mkShell pkgs.python313 "diffrax";
            default = mkShell pkgs.python313 "diffrax";
        };
    };
}
