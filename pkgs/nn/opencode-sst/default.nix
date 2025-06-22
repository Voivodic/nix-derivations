# Derivation for the installation of e3nn_jax
{ 
    # For building the derivation
    lib,
    buildNpmPackage,
    fetchFromGitHub,

    # Get nodejs
    nodejs,
}: 
# Derivation for e3nn_jax 
buildNpmPackage rec { 
    pname = "opencode"; 
    version = "0.1.117"; 

    src = fetchFromGitHub{ 
        owner = "sst"; 
        repo = "opencode"; 
        tag = "${version}"; 
        sha256 = "sha256-ydYpTSJ3HsX1szDwVHEsJdlj8j3nLvbFqlaS50tBmNk="; 
    }; 

    buildInputs = [
        nodejs
    ];

    meta = { 
        description = "AI code assistent"; 
        homepage = "https://opencode.ai/"; 
        license = lib.licenses.mit;
    }; 
}
