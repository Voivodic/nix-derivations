# Derivation for the installation of diffrax 
{ pkgs }: 
let 
    # Define the python version 
    python = pkgs.python312; 
    pythonPackages = pkgs.python312Packages; 
in 
    # Derivation for diffrax 
    pkgs.python312Packages.buildPythonPackage { 
        pname = "diffrax"; 
        version = "0.7"; 
        format = "pyproject";

        src = pkgs.fetchFromGitHub{ 
            owner = "patrick-kidger"; 
            repo = "diffrax"; 
            rev = "main"; 
            sha256 = ""; 
        }; 

        propagatedBuildInputs = [ 
            python
            pythonPackages.jax
            pythonPackages.jaxlib
            pythonPackages.equinox
            pythonPackages.lineax
            pythonPackages.optimistix
            pythonPackages.hatchling
        ]; 

        meta = { 
            description = "Python library solving ODE using jax"; 
            homepage = "https://docs.kidger.site/diffrax/"; 
        }; 
    }
