{
    description = "Test of the derivations in this folder";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs, nixpkgs-unstable, ... }: 
    let
        # Define the system
        system = "x86_64-linux";
        stable = import nixpkgs { system = "${system}"; };
        unstable = import nixpkgs-unstable { system = "${system}"; };

        # Call the packages in the Repo
        pyexshalos = unstable.python313Packages.callPackage ./pkgs/cosmo/pyexshalos {};
        e3nn-jax = unstable.python313Packages.callPackage ./pkgs/nn/e3nn_jax {};
        diffrax = unstable.python313Packages.callPackage ./pkgs/nn/diffrax {};
    in { 
        devShells.${system} = {
            pyexshalos = stable.mkShell {
                buildInputs = [
                    pyexshalos
                ];
            };
            e3nn-jax = stable.mkShell {
                buildInputs = [
                    e3nn-jax
                ];
            };
            diffrax = stable.mkShell {
                buildInputs = [
                    diffrax 
                ];
            };
        };
    };
}
