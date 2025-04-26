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
    cython,
    distutils,
}: 
# Derivation for pyexshalos 
buildPythonPackage rec { 
    pname = "class-pt"; 
    version = "2.0"; 

    src = fetchFromGitHub{ 
        owner = "Michalychforever"; 
        repo = "CLASS-PT"; 
        rev = "master";
        sha256 = "sha256-AlgQ1xkZYXu5FCzNJNOJJQfhpVC9I+su+P/bG6LLIl4="; 
    }; 

    nativeBuildInputs = [
        gcc
        gnumake
    ];

    buildInputs = [ 
        openblas
        distutils
    ]; 

    propagatedBuildInputs = [
        numpy
        cython
    ];

    configurePhase = ''
        sed -i '54c\OPENBLAS = ${openblas}/lib/libopenblas.so' Makefile
        sed -i '144c\all: class libclass.a' Makefile
        sed -i '189,197d' Makefile
        sed -i '39c\include_dirs=[nm.get_include(), "../include", "${openblas}/include"],' python/setup.py
        sed -i '42c\extra_link_args=["${openblas}/lib/libopenblas.so", "-lgomp"],' python/setup.py
        export HOME=$(mktemp -d)

        sed -i '23c\ctypedef np.int32_t DTYPE_i' python/classy.pyx
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
