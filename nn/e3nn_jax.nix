# Derivation for the installation of e3nn_jax
{ pkgs }: 
let 
    # Define the python version 
    python = pkgs.python312; 
    pythonPackages = pkgs.python312Packages; 
in 
    # Derivation for e3nn_jax 
    pkgs.python312Packages.buildPythonPackage { 
        pname = "e3nn-jax"; 
        version = "0.20.7"; 
        format = "pyproject";

        src = pkgs.fetchFromGitHub{ 
            owner = "e3nn"; 
            repo = "e3nn-jax"; 
            rev = "main"; 
            sha256 = "sha256-Z4Chry8KUNK+pr2yWtv9aUwj66Ofmrq8QT2B8BgEUj8="; 
        }; 

        propagatedBuildInputs = [ 
            python
            pythonPackages.jax
            pythonPackages.jaxlib
            pythonPackages.setuptools_scm
            pythonPackages.attrs
            pythonPackages.sympy
        ]; 

        meta = { 
            description = "Python library for E(3) NN using jax"; 
            homepage = "https://github.com/e3nn/e3nn-jax"; 
        }; 
    }
