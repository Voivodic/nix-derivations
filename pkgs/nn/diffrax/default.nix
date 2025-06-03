# Derivation for the installation of diffrax 
{ 
    # For building the derivation
    lib,
    buildPythonPackage,
    fetchFromGitHub,

    # For building the libraries
    hatchling,

    # Python dependencies
    jax,
    jax-cuda12-plugin,
    jax-cuda12-pjrt,
    jaxtyping,
    equinox,
    wadler-lindig,
    lineax,
    optimistix,
    typing-extensions
}: 
# Derivation for diffrax 
buildPythonPackage rec { 
    pname = "diffrax"; 
    version = "0.7.0"; 
    format = "pyproject";

    src = fetchFromGitHub{ 
        owner = "patrick-kidger";
        repo = "diffrax";
        tag = "v${version}";
        sha256 = "sha256-TBXcwNFYU1C9Pa0KwJeqfVixnJNFdg77HRXqZlSEQjY=";
    }; 

    buildInputs = [
        hatchling
        jax-cuda12-plugin
        jax-cuda12-pjrt
    ];

    propagatedBuildInputs = [ 
        jax 
        jaxtyping
        equinox
        wadler-lindig
        lineax
        optimistix 
        typing-extensions
    ]; 

    pythonImportsCheck = [ "diffrax" ];

    meta = { 
        description = "Python library for solving ODE using jax"; 
        homepage = "https://docs.kidger.site/diffrax/"; 
        license = lib.licenses.mit;
    }; 
}
