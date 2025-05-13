{
    description = "Test of the derivations taken directly from github";

    inputs = {
        nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        gitpkgs.url = "github:Voivodic/nix-derivations";
        gitpkgs.inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    outputs = { self, nixpkgs-stable, gitpkgs, ... }: 
    let
        # Define the system
        system = "x86_64-linux";
        stable = import nixpkgs-stable { system = "${system}"; };
    in { 
        devShells.${system} = {
            pyexshalos = stable.mkShell {
                buildInputs = [
                    gitpkgs.packages.${system}.pyexshalos
                ];
            };
            class-pt = stable.mkShell {
                buildInputs = [
                    gitpkgs.packages.${system}.class-pt
                ];
            };
            getdist = stable.mkShell {
                buildInputs = [
                    gitpkgs.packages.${system}.getdist
                ];
            };
            e3nn-jax = stable.mkShell {
                buildInputs = [
                    gitpkgs.packages.${system}.e3nn-jax
                ];
            };
            diffrax = stable.mkShell {
                buildInputs = [
                    gitpkgs.packages.${system}.diffrax
                ];
            };
        };
    };
}
