{
    description = "Test derivations";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        gitpkgs.url = "path:../";
        gitpkgs.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = { self, nixpkgs, gitpkgs, ... }:
    let
        system = "x86_64-linux";

        pkgs-cpu = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ gitpkgs.overlays.default ];
        };

        pkgs-gpu = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            config.cudaSupport = true;
            overlays = [ gitpkgs.overlays.default ];
        };

        mkTest = name: env: testCode:
            let
                script = pkgs-cpu.writeShellScriptBin name ''
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

        # --- Non-GPU package tests ---
        pyexshalos-test = mkTest "pyexshalos" (pkgs-cpu.python313.withPackages (ps: [ ps.pyexshalos ])) ''
            import pyexshalos
            print('pyexshalos: OK')
        '';

        class-pt-test = mkTest "class-pt" (pkgs-cpu.python313.withPackages (ps: [ ps.class-pt ])) ''
            import classy
            print('class-pt: OK')
        '';

        getdist-test = mkTest "getdist" (pkgs-cpu.python313.withPackages (ps: [ ps.getdist ])) ''
            import getdist
            print('getdist: OK')
        '';

        # --- GPU package CPU tests ---
        e3nn-jax-cpu-test = mkTest "e3nn-jax" (pkgs-cpu.python313.withPackages (ps: [ ps.e3nn-jax ])) ''
            import e3nn_jax
            print('e3nn-jax: OK')
        '';

        diffrax-cpu-test = mkTest "diffrax" (pkgs-cpu.python313.withPackages (ps: [ ps.diffrax ])) ''
            import diffrax
            print('diffrax: OK')
        '';

        # --- GPU package GPU tests (strict: fail if no GPU) ---
        e3nn-jax-gpu-test = mkTest "e3nn-jax" (pkgs-gpu.python313.withPackages (ps: [ ps.e3nn-jax ])) ''
            import e3nn_jax
            print('e3nn-jax: import OK')
            import jax
            devs = jax.devices()
            print('Devices:', devs)
            assert any('gpu' in str(d).lower() or 'cuda' in str(d).lower() for d in devs), 'No GPU found'
            print('e3nn-jax: GPU OK')
        '';

        diffrax-gpu-test = mkTest "diffrax" (pkgs-gpu.python313.withPackages (ps: [ ps.diffrax ])) ''
            import diffrax
            print('diffrax: import OK')
            import jax
            devs = jax.devices()
            print('Devices:', devs)
            assert any('gpu' in str(d).lower() or 'cuda' in str(d).lower() for d in devs), 'No GPU found'
            print('diffrax: GPU OK')
        '';

        # --- GPU package full tests (lenient: skip GPU if unavailable) ---
        e3nn-jax-test = mkTest "e3nn-jax" (pkgs-gpu.python313.withPackages (ps: [ ps.e3nn-jax ])) ''
            import e3nn_jax
            print('e3nn-jax: import OK')
            import jax
            devs = jax.devices()
            print('Devices:', devs)
            if any('gpu' in str(d).lower() or 'cuda' in str(d).lower() for d in devs):
                print('e3nn-jax: GPU OK')
            else:
                print('e3nn-jax: GPU not available (skipped)')
        '';

        diffrax-test = mkTest "diffrax" (pkgs-gpu.python313.withPackages (ps: [ ps.diffrax ])) ''
            import diffrax
            print('diffrax: import OK')
            import jax
            devs = jax.devices()
            print('Devices:', devs)
            if any('gpu' in str(d).lower() or 'cuda' in str(d).lower() for d in devs):
                print('diffrax: GPU OK')
            else:
                print('diffrax: GPU not available (skipped)')
        '';

        # --- Combined tests ---
        test-cpu = mkTest "test" (pkgs-cpu.python313.withPackages (ps: [
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

        test-gpu = mkTest "test" (pkgs-gpu.python313.withPackages (ps: [
            ps.e3nn-jax ps.diffrax
        ])) ''
            import sys
            errors = []
            ${importCheck "e3nn-jax" "e3nn_jax"}
            ${importCheck "diffrax" "diffrax"}
            import jax
            devs = jax.devices()
            print('Devices:', devs)
            if not any('gpu' in str(d).lower() or 'cuda' in str(d).lower() for d in devs):
                errors.append('GPU')
                print('GPU: FAILED - No GPU found')
            else:
                print('GPU: OK')
            if errors:
                print('Failed:', ', '.join(errors))
                sys.exit(1)
            print('All GPU tests passed')
        '';

        test = mkTest "test" (pkgs-gpu.python313.withPackages (ps: [
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
            if any('gpu' in str(d).lower() or 'cuda' in str(d).lower() for d in devs):
                print('GPU: OK')
            else:
                print('GPU: not available (skipped)')
            if errors:
                print('Failed:', ', '.join(errors))
                sys.exit(1)
            print('All tests passed')
        '';
    in {
        packages.${system} = {
            pyexshalos = pyexshalos-test;
            pyexshalos-cpu = pyexshalos-test;
            class-pt = class-pt-test;
            class-pt-cpu = class-pt-test;
            getdist = getdist-test;
            getdist-cpu = getdist-test;
            e3nn-jax = e3nn-jax-test;
            e3nn-jax-cpu = e3nn-jax-cpu-test;
            e3nn-jax-gpu = e3nn-jax-gpu-test;
            diffrax = diffrax-test;
            diffrax-cpu = diffrax-cpu-test;
            diffrax-gpu = diffrax-gpu-test;
            inherit test test-cpu test-gpu;
        };
    };
}
