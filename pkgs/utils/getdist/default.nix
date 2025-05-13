# Derivation for the installation of getdist
{ 
    # For building the derivation
    lib,
    buildPythonPackage,
    fetchFromGitHub,

    # Python dependencies
    setuptools_scm,
    matplotlib,
    scipy,
    attrs,
    sympy,
}: 
# Derivation for getdist 
buildPythonPackage rec { 
    pname = "getdist"; 
    version = "1.6.4"; 

    src = fetchFromGitHub{ 
        owner = "cmbant"; 
        repo = "getdist"; 
        tag = "${version}"; 
        sha256 = ""; 
    }; 

    buildInputs = [
        setuptools_scm
    ];

    propagatedBuildInputs = [ 
        matplotlib
        scipy
        attrs
        sympy
    ]; 

    pythonImportsCheck = [ "getdist" ];

    meta = { 
        description = "GetDist is a Python package for analysing and plotting Monte Carlo (or other) samples."; 
        homepage = "https://getdist.readthedocs.io/en/latest/"; 
        license = lib.licenses.mit;
    }; 
}
