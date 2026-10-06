{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-26.05";
  };

  outputs = inputs: {
    packages = builtins.mapAttrs (system: pkgs: 
    let
      pnpm= pkgs.pnpm.override { nodejs = pkgs.nodejs_26; };
    in{
      default = pkgs.stdenv.mkDerivation (finalAttrs: {
        pname = "arcane-marketplace";
        version = "0.1.0-unstable";

        REGISTRY_NAME = "Arcane Marketplace";
        REGISTRY_DESCRIPTION = "A collections of Arcane Templates for Homelab / personal-use.";
        REGISTRY_AUTHOR = "socheatsok78";
        REGISTRY_URL = "https://github.com/socheatsok78/docker-marketplace";
        PUBLIC_BASE = "https://socheatsok78.github.io/arcane-marketplace/templates";

        src = pkgs.fetchFromGitHub {
          owner = "getarcaneapp";
          repo = "templates";
          rev = "main";
          sha256 = "sha256-UE388a4DTD8gXAMD3D5ISAJPAOEIReI7ZjshByvgP54=";
        };

        arcane-marketplace = ./.;

        nativeBuildInputs = with pkgs; [
          nodejs # in case scripts are run outside of a pnpm call
          pnpmConfigHook
          pnpm # At least required by pnpmConfigHook, if not other (custom) phases
        ];

        pnpmDeps = pkgs.fetchPnpmDeps {
          inherit (finalAttrs) pname version src;
          inherit (pkgs) pnpm;
          fetcherVersion = 4;
          hash = "sha256-2udID2AohfXnLjQVS9sHpfv+pcDNEf1NDtTRLf2OvU0=";
        };

        configurePhase = ''
          runHook preConfigure

          # We borrow the functionality from the source, so we replace the templates directory with our own
          rm -rf ./templates
          rm registry.json

          # Copy registry.jon from current project, so the script can auto-bump the version
          if [[ -f "${finalAttrs.arcane-marketplace}/registry.json" ]]; then
            cp "${finalAttrs.arcane-marketplace}/registry.json" ./registry.json
            chmod 0777 ./registry.json
          fi

          # Create a symlink to the templates directory
          ln -s "${finalAttrs.arcane-marketplace}/templates" ./templates

          # Patching public/index.html
          sed -i 's|Arcane Templates Registry|${finalAttrs.REGISTRY_NAME}|g' public/index.html
          sed -i 's|Community Docker Compose catalog|${finalAttrs.REGISTRY_DESCRIPTION}|g' public/index.html
          sed -i 's|location.origin|location.href|g' public/index.html

          runHook postConfigure
        '';

        buildPhase = ''
          runHook preBuild

          pnpm run generate

          mkdir -p $out
          cp public/index.html $out/index.html
          cp registry.json $out/registry.json

          runHook postBuild
        '';
      });
    }) inputs.nixpkgs.legacyPackages;
  };
}
