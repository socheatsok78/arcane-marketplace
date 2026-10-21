it: README build registry.json gh-pages

README:
	@./README.sh
build:
	@nix build -L
.PHONY: registry.json
registry.json:
	@cat result/registry.json > registry.json
gh-pages:
	@./scripts/gh-pages.sh
