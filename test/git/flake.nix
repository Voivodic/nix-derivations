{
    description = "Test of the derivations taken directly from github";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        gitpkgs.url = "github:Voivodic/nix-derivations";
        gitpkgs.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = { self, nixpkgs, gitpkgs, ... }: 
    let
        # Define the system
        system = "x86_64-linux";
        pkgs = import nixpkgs { 
            system = "${system}";
        };
        gpkgs = gitpkgs.packages.${system};
    in { 
        devShells.${system} = {
            pyexshalos = pkgs.mkShell {
                buildInputs = [
                    gpkgs.python313.pyexshalos
                ];
            };
            class-pt = pkgs.mkShell {
                buildInputs = [
                    gpkgs.python313.class-pt
                ];
            };
            getdist = pkgs.mkShell {
                buildInputs = [
                    gpkgs.python313.getdist
                ];
            };
            e3nn-jax = pkgs.mkShell {
                buildInputs = [
                    gpkgs.python313.e3nn-jax
                ];
            };
            diffrax = pkgs.mkShell {
                buildInputs = [
                    gpkgs.python313.diffrax
                ];
            };
            e3nn-jax-cuda = pkgs.mkShell {
                buildInputs = [
                    gpkgs.python313.e3nn-jax-cuda
                ];
            };
            diffrax-cuda = pkgs.mkShell {
                buildInputs = [
                    gpkgs.python313.diffrax-cuda
                ];
            };
        };
    };
}
