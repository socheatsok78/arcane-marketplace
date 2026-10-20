it: README build registry.json gh-pages

README:
	@./README.sh
build:
	@nix build -L
registry.json:
	@cat result/registry.json > registry.json
gh-pages:
	@./scripts/gh-pages.sh
