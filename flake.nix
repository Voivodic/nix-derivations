{
    description = "Voivodic's custom packages for nix";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils, ... }:
        let
            localOverlay = final: prev: {
                pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
                    (python-final: python-prev: {
                        # Cosmo
                        pyexshalos = python-final.callPackage ./pkgs/cosmo/pyexshalos {};
                        class-pt = python-final.callPackage ./pkgs/cosmo/class-pt {};

                        # NN
                        e3nn-jax = python-final.callPackage ./pkgs/nn/e3nn-jax { 
                            cudaSupport = prev.config.cudaSupport or false; 
                        };
                        diffrax = python-final.callPackage ./pkgs/nn/diffrax { 
                            cudaSupport = prev.config.cudaSupport or false; 
                        };

                        # Utils
                        getdist = python-final.callPackage ./pkgs/utils/getdist {};
                    })
                ];
            };
        in
        flake-utils.lib.eachDefaultSystem (system:
            let
                makePkgs = cudaSupport: import nixpkgs { 
                    inherit system;
                    config.allowUnfree = true;
                    config.cudaSupport = cudaSupport;
                    overlays = [ localOverlay ];
                };

                pkgs = makePkgs false;
                pkgs-cuda = makePkgs true;

                extractPackages = p: {
                    inherit (p.python313Packages) pyexshalos class-pt e3nn-jax diffrax getdist;

                    python312 = {
                        inherit (p.python312Packages) pyexshalos class-pt e3nn-jax diffrax getdist;
                    };
                    python313 = {
                        inherit (p.python313Packages) pyexshalos class-pt e3nn-jax diffrax getdist;
                    };
                };

                # --- Test infrastructure ---
                mkTest = name: env: testCode:
                    let
                        script = pkgs.writeShellScriptBin name ''
                            ${env}/bin/python << 'PYEOF'
                            ${testCode}
                            PYEOF
                        '';
                    in
                    script // { meta = (script.meta or {}) // { mainProgram = name; }; };

                importCheck = name: importName: ''
                    try:
                        import ${importName}
                        print('${name}: OK')
                    except Exception as e:
                        print('${name}: FAILED - ' + str(e))
                        errors.append('${name}')
                '';

                hasGPU = "any('gpu' in str(d).lower() or 'cuda' in str(d).lower() for d in devs)";

                # --- Non-GPU package tests ---
                pyexshalos-test = mkTest "pyexshalos" (pkgs.python313.withPackages (ps: [ ps.pyexshalos ])) ''
                    import pyexshalos
                    print('pyexshalos: OK')
                '';

                class-pt-test = mkTest "class-pt" (pkgs.python313.withPackages (ps: [ ps.class-pt ])) ''
                    import classy
                    print('class-pt: OK')
                '';

                getdist-test = mkTest "getdist" (pkgs.python313.withPackages (ps: [ ps.getdist ])) ''
                    import getdist
                    print('getdist: OK')
                '';

                # --- GPU package CPU tests ---
                e3nn-jax-cpu-test = mkTest "e3nn-jax" (pkgs.python313.withPackages (ps: [ ps.e3nn-jax ])) ''
                    import e3nn_jax
                    print('e3nn-jax: OK')
                '';

                diffrax-cpu-test = mkTest "diffrax" (pkgs.python313.withPackages (ps: [ ps.diffrax ])) ''
                    import diffrax
                    print('diffrax: OK')
                '';

                # --- GPU package GPU tests (strict: fail if no GPU) ---
                e3nn-jax-gpu-test = mkTest "e3nn-jax" (pkgs-cuda.python313.withPackages (ps: [ ps.e3nn-jax ])) ''
                    import e3nn_jax
                    print('e3nn-jax: import OK')
                    import jax
                    devs = jax.devices()
                    print('Devices:', devs)
                    assert ${hasGPU}, 'No GPU found'
                    print('e3nn-jax: GPU OK')
                '';

                diffrax-gpu-test = mkTest "diffrax" (pkgs-cuda.python313.withPackages (ps: [ ps.diffrax ])) ''
                    import diffrax
                    print('diffrax: import OK')
                    import jax
                    devs = jax.devices()
                    print('Devices:', devs)
                    assert ${hasGPU}, 'No GPU found'
                    print('diffrax: GPU OK')
                '';

                # --- GPU package full tests (lenient: skip GPU if unavailable) ---
                e3nn-jax-test = mkTest "e3nn-jax" (pkgs-cuda.python313.withPackages (ps: [ ps.e3nn-jax ])) ''
                    import e3nn_jax
                    print('e3nn-jax: import OK')
                    import jax
                    devs = jax.devices()
                    print('Devices:', devs)
                    if ${hasGPU}:
                        print('e3nn-jax: GPU OK')
                    else:
                        print('e3nn-jax: GPU not available (skipped)')
                '';

                diffrax-test = mkTest "diffrax" (pkgs-cuda.python313.withPackages (ps: [ ps.diffrax ])) ''
                    import diffrax
                    print('diffrax: import OK')
                    import jax
                    devs = jax.devices()
                    print('Devices:', devs)
                    if ${hasGPU}:
                        print('diffrax: GPU OK')
                    else:
                        print('diffrax: GPU not available (skipped)')
                '';

                # --- Combined tests ---
                test-cpu = mkTest "test" (pkgs.python313.withPackages (ps: [
                    ps.pyexshalos ps.class-pt ps.getdist ps.e3nn-jax ps.diffrax
                ])) ''
                    import sys
                    errors = []
                    ${importCheck "pyexshalos" "pyexshalos"}
                    ${importCheck "class-pt" "classy"}
                    ${importCheck "getdist" "getdist"}
                    ${importCheck "e3nn-jax" "e3nn_jax"}
                    ${importCheck "diffrax" "diffrax"}
                    if errors:
                        print('Failed:', ', '.join(errors))
                        sys.exit(1)
                    print('All CPU tests passed')
                '';

                test-gpu = mkTest "test" (pkgs-cuda.python313.withPackages (ps: [
                    ps.e3nn-jax ps.diffrax
                ])) ''
                    import sys
                    errors = []
                    ${importCheck "e3nn-jax" "e3nn_jax"}
                    ${importCheck "diffrax" "diffrax"}
                    import jax
                    devs = jax.devices()
                    print('Devices:', devs)
                    if not ${hasGPU}:
                        errors.append('GPU')
                        print('GPU: FAILED - No GPU found')
                    else:
                        print('GPU: OK')
                    if errors:
                        print('Failed:', ', '.join(errors))
                        sys.exit(1)
                    print('All GPU tests passed')
                '';

                test = mkTest "test" (pkgs-cuda.python313.withPackages (ps: [
                    ps.pyexshalos ps.class-pt ps.getdist ps.e3nn-jax ps.diffrax
                ])) ''
                    import sys
                    errors = []
                    ${importCheck "pyexshalos" "pyexshalos"}
                    ${importCheck "class-pt" "classy"}
                    ${importCheck "getdist" "getdist"}
                    ${importCheck "e3nn-jax" "e3nn_jax"}
                    ${importCheck "diffrax" "diffrax"}
                    import jax
                    devs = jax.devices()
                    print('Devices:', devs)
                    if ${hasGPU}:
                        print('GPU: OK')
                    else:
                        print('GPU: not available (skipped)')
                    if errors:
                        print('Failed:', ', '.join(errors))
                        sys.exit(1)
                    print('All tests passed')
                '';
            in {
                packages = (extractPackages pkgs) // {
                    cuda = extractPackages pkgs-cuda;

                    # Individual package tests
                    pyexshalos-test = pyexshalos-test;
                    pyexshalos-cpu = pyexshalos-test;
                    class-pt-test = class-pt-test;
                    class-pt-cpu = class-pt-test;
                    getdist-test = getdist-test;
                    getdist-cpu = getdist-test;
                    e3nn-jax-test = e3nn-jax-test;
                    e3nn-jax-cpu = e3nn-jax-cpu-test;
                    e3nn-jax-gpu = e3nn-jax-gpu-test;
                    diffrax-test = diffrax-test;
                    diffrax-cpu = diffrax-cpu-test;
                    diffrax-gpu = diffrax-gpu-test;

                    # Combined tests
                    test = test;
                    test-cpu = test-cpu;
                    test-gpu = test-gpu;
                };

                legacyPackages = pkgs;
                legacyPackagesCUDA = pkgs-cuda;
            }
        ) // {
            overlays.default = localOverlay;
        };
}
