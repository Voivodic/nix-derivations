{ system ? builtins.currentSystem, config ? {} }:

let
    pkgs = import <nixpkgs> { 
        inherit system;
        config.allowUnfree = true;
        config.cudaSupport = config.cudaSupport or false;
    };
    cudaSupport = config.cudaSupport or false;
in
{
    python314 = {
        pyexshalos = pkgs.python314Packages.callPackage ./pkgs/cosmo/pyexshalos {};
        class-pt = pkgs.python314Packages.callPackage ./pkgs/cosmo/class-pt {};
        e3nn-jax = pkgs.python314Packages.callPackage ./pkgs/nn/e3nn-jax { inherit cudaSupport; };
        diffrax = pkgs.python314Packages.callPackage ./pkgs/nn/diffrax { inherit cudaSupport; };
        getdist = pkgs.python314Packages.callPackage ./pkgs/utils/getdist {};
    };
    python313 = {
        pyexshalos = pkgs.python313Packages.callPackage ./pkgs/cosmo/pyexshalos {};
        class-pt = pkgs.python313Packages.callPackage ./pkgs/cosmo/class-pt {};
        e3nn-jax = pkgs.python313Packages.callPackage ./pkgs/nn/e3nn-jax { inherit cudaSupport; };
        diffrax = pkgs.python313Packages.callPackage ./pkgs/nn/diffrax { inherit cudaSupport; };
        getdist = pkgs.python313Packages.callPackage ./pkgs/utils/getdist {};
    };
}
