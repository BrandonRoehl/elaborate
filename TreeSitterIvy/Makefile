TREE_SITTER ?= npx --yes tree-sitter-cli@0.25.10

.PHONY: build
build: src/parser.c
	swift build

# Regenerate the parser from the grammar
src/parser.c: grammar.js
	$(TREE_SITTER) generate

.PHONY: generate
generate:
	$(TREE_SITTER) generate

.PHONY: test
test: src/parser.c
	swift test

.PHONY: clean
clean:
	rm -rf .build src/parser.c src/grammar.json src/node-types.json src/tree_sitter
