{
    description = "Test the derivations taken locally";

    inputs = {
        nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs-stable, nixpkgs-unstable, ... }: 
    let
        # Define the system
        system = "x86_64-linux";
        stable = import nixpkgs-stable { 
            system = "${system}";
            config.allowUnfree = true;
        };
        unstable = import nixpkgs-unstable { 
            system = "${system}";
            config.allowUnfree = true;
        };

        # Call the packages in the Repo
        pyexshalos = unstable.python313Packages.callPackage ./../../pkgs/cosmo/pyexshalos {};
        class-pt = unstable.python313Packages.callPackage ./../../pkgs/cosmo/class-pt {};
        getdist = unstable.python313Packages.callPackage ./../../pkgs/utils/getdist {};
        e3nn-jax = unstable.python313Packages.callPackage ./../../pkgs/nn/e3nn_jax {};
        diffrax = unstable.python313Packages.callPackage ./../../pkgs/nn/diffrax { };
    in { 
        devShells.${system} = {
            pyexshalos = stable.mkShell {
                buildInputs = [
                    pyexshalos
                ];
            };
            class-pt = stable.mkShell {
                buildInputs = [
                    class-pt 
                ];
            };
            getdist = stable.mkShell {
                buildInputs = [
                    getdist
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
