{   
    # For building the derivation
    lib,
    buildNpmPackage,
    fetchFromGitHub,
    nodejs,
}:

buildNpmPackage {
    pname = "gemini-cli";
    version = "0.1.0";

    # Fetch the source code directly from GitHub
    src = fetchFromGitHub {
        owner = "google-gemini";
        repo = "gemini-cli";
        rev = "main";
        sha256 = "sha256-YOUR_SHA256_HASH_HERE";
    };

    # Node.js is required for building npm packages
    nativeBuildInputs = [ nodejs ];

    npmDepsHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

    # Metadata for the package
    meta = {
        description = "Google Gemini CLI: An open-source AI agent that brings the power of Gemini directly into your terminal.";
        homepage = "https://github.com/google-gemini/gemini-cli";
        license = lib.licenses.apache20;
    };
}
