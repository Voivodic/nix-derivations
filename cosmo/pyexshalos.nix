# Derivation for the installation of pyExSHalos 
{ 
    # For building the derivation
    stdenv,
    lib,
    buildPythonPackage,
    fetchFromGitHub,

    # For building the libraries
    gcc,
    setuptools,

    # Dependencies
    fftw,
    fftwFloat,
    gsl,

    # Python dependencies
    numpy,
    scipy,
}: 
let 
    # Derivation for voro++ (used in ExSHalos) 
    voroPP = stdenv.mkDerivation { 
        pname = "voro++"; 
        version = "0.5"; 

        src = fetchFromGitHub{ 
            owner = "chr1shr"; 
            repo = "voro"; 
            rev = "master"; 
            sha256 = "sha256-F6KersvAa/LKEFjfolGWPjxlsmfFh5F/cV2CrmO8ntA="; 
        }; 

        nativeBuildInputs = [
            gcc
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
# Derivation for pyexshalos 
buildPythonPackage rec { 
    pname = "pyexshalos"; 
    version = "0.1.0"; 

    src = fetchFromGitHub{ 
        owner = "Voivodic"; 
        repo = "ExSHalos"; 
        tag = "v${version}";
        sha256 = "sha256-F7khUGrD7sdlz3YIABxf4wrOuL8eww0NCIdmNRF4+mY="; 
    }; 

    nativeBuildInputs = [
        gcc
    ];

    buildInputs = [ 
        fftw 
        fftwFloat 
        gsl 
        voroPP 
        setuptools
    ]; 

    propagatedBuildInputs = [ 
        numpy 
        scipy 
    ]; 

    pythonImportsCheck = [ "pyexshalos" ];

    meta = { 
        description = "Python interface to ExSHalos"; 
        homepage = "https://voivodic.github.io/ExSHalos/"; 
        license = lib.licenses.mit;
    }; 
}
