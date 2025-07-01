{ 
    buildNpmPackage,
    fetchFromGitHub,
}:

buildNpmPackage {
    pname = "opencode";
    version = "0.1.0"; # Check package.json for the correct version

    src = fetchFromGitHub {
        owner = "sst";
        repo = "opencode";
        rev = "main"; # Or a specific tag/commit
        hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with the actual hash
    };

    npmDepsHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="; # Replace with the actual hash

    # The opencode project is a monorepo, so we need to specify the workspace
    npmWorkspace = "packages/opencode";

    installPhase = ''
        runHook preInstall
        npm run build
        npm pack --workspace packages/opencode
        tar -xzf sst-opencode-*.tgz
        mkdir -p $out/bin
        mv package/bin/opencode $out/bin/
        runHook postInstall
    '';

    meta = {
        description = "AI coding agent, built for the terminal.";
        homepage = "https://github.com/sst/opencode";
    };
}
