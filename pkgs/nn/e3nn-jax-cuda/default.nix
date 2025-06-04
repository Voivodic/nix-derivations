# Derivation for the installation of e3nn_jax
{ 
    # For building the derivation
    lib,
    buildPythonPackage,
    fetchFromGitHub,

    # Python dependencies
    jax,
    jax-cuda12-plugin,
    jax-cuda12-pjrt,
    setuptools_scm,
    attrs,
    sympy,
}: 
# Derivation for e3nn_jax 
buildPythonPackage rec { 
    pname = "e3nn-jax"; 
    version = "0.20.7"; 
    format = "pyproject";

    src = fetchFromGitHub{ 
        owner = "e3nn"; 
        repo = "e3nn-jax"; 
        tag = "${version}"; 
        sha256 = "sha256-ydYpTSJ3HsX1szDwVHEsJdlj8j3nLvbFqlaS50tBmNk="; 
    }; 

    buildInputs = [
        setuptools_scm
        jax-cuda12-plugin
        jax-cuda12-pjrt
    ];

    propagatedBuildInputs = [ 
        jax
        attrs
        sympy
    ]; 

    pythonImportsCheck = [ "e3nn_jax" ];

    meta = { 
        description = "Python library for E(3) NN using jax"; 
        homepage = "https://github.com/e3nn/e3nn-jax"; 
        license = lib.licenses.mit;
    }; 
}
