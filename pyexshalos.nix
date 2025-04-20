# Derivation for the installation of pyExSHalos 
{ pkgs }: 
let 
    # Define the python version 
    python = pkgs.python312; 
    pythonPackages = pkgs.python312Packages; 

    # Derivation for voro++ (used in ExSHalos) 
    voroPP = pkgs.stdenv.mkDerivation { 
        pname = "voro++"; 
        version = "0.5"; 

        src = pkgs.fetchFromGitHub{ 
            owner = "chr1shr"; 
            repo = "voro"; 
            rev = "master"; 
            sha256 = ""; 
        }; 

        buildInputs = [
            pkgs.gcc
        ]; 

        buildPhase = '' 
            make CFLAGS="$CFLAGS -Wall -ansi -pedantic -O3 -fPIC" 
        ''; 

        installPhase = '' 
            make install PREFIX=$out
        ''; 

        meta = { 
            description = "A three-dimensional Voronoi cell library in C++"; 
            homepage = "https://math.lbl.gov/voro++/"; 
        }; 
    }; 
in 
{
    # Derivation for pyexshalos 
    pkgs.python312Packages.buildPythonPackage { 
        pname = "pyexshalos"; 
        version = "0.1.0"; 

        src = pkgs.fetchFromGitHub{ 
            owner = "Voivodic"; 
            repo = "ExSHalos"; 
            rev = "main"; 
            sha256 = ""; 
        }; 

        buildInputs = [ 
            pkgs.gcc 
            pkgs.fftw 
            pkgs.fftwFloat 
            pkgs.gsl 
            voroPP 
        ]; 

        propagatedBuildInputs = [ 
            python 
            pythonPackages.setuptools 
            pythonPackages.numpy 
            pythonPackages.scipy 
        ]; 

        meta = { 
            description = "Python interface to ExSHalos"; 
            homepage = "https://voivodic.github.io/ExSHalos/"; 
        }; 
    };
};
