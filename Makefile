it: README
	@nix build -L
	@cat result/registry.json > registry.json
	@cat result/index.html > index.html

README:
	@./README.sh
