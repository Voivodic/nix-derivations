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
        version = "0.5.0"; 
        format = "pyproject";

        src = pkgs.fetchPypi{ 
            pname = "diffrax";
            version = "0.5.0";
            sha256 = "sha256-LmZwG1RXmIGK80qRMoh7NUyTtbR+EzyZhuI6fPYAqTc";
        }; 

        propagatedBuildInputs = [ 
            python
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
