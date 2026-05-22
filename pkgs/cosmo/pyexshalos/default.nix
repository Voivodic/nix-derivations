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
# Derivation for pyexshalos 
buildPythonPackage rec { 
    pname = "pyexshalos"; 
    version = "1.0.0"; 
    format = "setuptools"; 

    src = fetchFromGitHub{ 
        owner = "Voivodic"; 
        repo = "exshalos"; 
        tag = "v${version}";
        sha256 = "sha256-Mi60FWRop8FoZGLH2IXf8wi2cNPlzh2+gqAtZFLEQhM="; 
    }; 

    nativeBuildInputs = [
        gcc
    ];

    buildInputs = [ 
        fftw 
        fftwFloat 
        gsl 
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
