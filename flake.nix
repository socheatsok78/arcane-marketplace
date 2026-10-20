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
        REGISTRY_DESCRIPTION = "A collections of Arcane Templates for Homelab / personal-use";
        REGISTRY_AUTHOR = "socheatsok78";
        REGISTRY_URL = "https://github.com/socheatsok78/docker-marketplace";
        PUBLIC_BASE = "https://arcane-marketplace.socheat.dev/templates";

        src = pkgs.fetchFromGitHub {
          owner = "getarcaneapp";
          repo = "templates";
          rev = "main";
          sha256 = "sha256-ua1ey/dMqz6F3Kh3w70yA8AqfyOxjnv1QxbRZm0DET0=";
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
          hash = "sha256-/ig19izsGa6W527vrvEqIcaGparaVf6Jc0Y+5+fNiYI=";
        };

        patches = [
          patches/app.html.patch
          patches/lib+components+SiteHeader.svelte.patch
          patches/routes+docs+page.svelte.patch
          patches/routes+layout.svelte.patch
          patches/routes+page.svelte.patch
        ];

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
          cp -R "${finalAttrs.arcane-marketplace}/templates/." ./templates

          runHook postConfigure
        '';

        buildPhase = ''
          runHook preBuild

          pnpm run generate
          pnpm run stage

          mkdir -p $out
          cp -R build/. $out/

          runHook postBuild
        '';
      });
    }) inputs.nixpkgs.legacyPackages;
  };
}
