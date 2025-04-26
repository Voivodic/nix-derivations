# Derivation for the installation of pyExSHalos 
{ 
    # For building the derivation
    stdenv,
    lib,
    fetchFromGitHub,

    # For building the libraries
    gcc,
    make,

    # Dependencies
    openblas,
}: 
let 
    
in 
# Derivation for pyexshalos 
stdenv.mkDerivation rec { 
    pname = "class-pt"; 
    version = "2.0"; 

    src = fetchFromGitHub{ 
        owner = "Michalychforever"; 
        repo = "CLASS-PT"; 
        tag = "v${version}";
        sha256 = ""; 
    }; 

    nativeBuildInputs = [
        gcc
        make
    ];

    buildInputs = [ 
        openblas 
    ]; 

    buildPhase = ''
        make
    '';

    installPhase = ''
        make install
    '';

    pythonImportsCheck = [ "classy" ];

    meta = { 
        description = "Code for computation of 1-loop power spectrum"; 
        homepage = "https://github.com/Michalychforever/CLASS-PT"; 
        license = lib.licenses.mit;
    }; 
}
