{ 
    stdenv,
    lib,
    fetchFromGitHub,
    buildPythonPackage,

    gcc,
    gnumake,

    openblas,

    numpy,
    cython,
    scipy,
}: 

buildPythonPackage rec { 
    pname = "class-pt"; 
    version = "3.0"; 
    format = "setuptools";

    src = fetchFromGitHub{ 
        owner = "Michalychforever"; 
        repo = "CLASS-PT"; 
        rev = "09d5531a4ec61187d84f506e9fdaf7fdcc8c7718";
        sha256 = "19h2pkgwa8zal057i2rg3wq3kdhpz4lab48haxj6yc1j94a1kb89"; 
    }; 

    nativeBuildInputs = [
        gcc
        gnumake
    ];

    buildInputs = [ 
        openblas
    ]; 

    propagatedBuildInputs = [
        numpy
        cython
        scipy
    ];

    OPENBLAS_PATH = "${openblas}/lib";

    buildPhase = ''
        make clean
        make libclass.a
    '';

    installPhase = ''
        cd python
        mkdir -p dist
        OPENBLAS_PATH="${openblas}/lib" python setup.py install --prefix=$out 
    '';

    pythonImportsCheck = [ "classy" ];

    meta = { 
        description = "Code for computation of 1-loop power spectrum"; 
        homepage = "https://github.com/Michalychforever/CLASS-PT"; 
        license = lib.licenses.mit;
    }; 
}
