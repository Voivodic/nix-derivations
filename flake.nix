{
    description = "Test of the derivations in this folder";

    inputs = {
        nixpkgs.url = github:NixOS/nixpkgs/nixos-24.11;
    };

    outputs = { self, nixpkgs, ... } @ inputs: 
    let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
    in
    {
        devShells.${system}.default = pkgs.mkShell {
            packages = [
                (import ./pyexshalos.nix { })
            ];
        };
    };
}

