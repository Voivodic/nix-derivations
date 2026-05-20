# Derivation for the installation of pyExSHalos 
{ 
    # For building the derivation
    stdenv,
    lib,
    fetchFromGitHub,
    buildPythonPackage,

    # For building the libraries
    gcc,
    gnumake,

    # Dependencies
    openblas,

    # Python dependencies
    numpy,
    scipy,
    pip,
    cython,
    distutils,
}: 
# Derivation for pyexshalos 
buildPythonPackage rec { 
    pname = "class-pt"; 
    version = "2.0"; 
    format = "setuptools"; 

    src = fetchFromGitHub{ 
        owner = "Michalychforever"; 
        repo = "CLASS-PT"; 
        rev = "master";
        sha256 = "sha256-Ca0ZFEkyMG9kVxCRpSj5F7Y5MB8vi3gKoOojxd+8AqY="; 
    }; 

    nativeBuildInputs = [
        gcc
        gnumake
    ];

    buildInputs = [ 
        pip
        openblas
        distutils
    ]; 

    propagatedBuildInputs = [
        numpy
        scipy
        cython
    ];

    configurePhase = ''
        sed -i '54c\OPENBLAS = ${openblas}/lib/libopenblas.so' Makefile
        sed -i '144c\all: class libclass.a' Makefile
        sed -i '189,197d' Makefile
        export HOME=$(mktemp -d)
    '';

    buildPhase = ''
        make clean
        make OPENBLAS="${openblas}/lib/libopenblas.so"
    '';

    installPhase = ''
        cd python
        mkdir -p dist
        python setup.py install --prefix=$out 
    '';

    pythonImportsCheck = [ "classy" ];

    meta = { 
        description = "Code for computation of 1-loop power spectrum"; 
        homepage = "https://github.com/Michalychforever/CLASS-PT"; 
        license = lib.licenses.mit;
    }; 
}
