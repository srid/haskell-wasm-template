# List available recipes
default:
    @just --list

# Build the WASM module and generate JS glue code
build:
    #!/usr/bin/env bash
    set -euo pipefail

    echo ":: Building with wasm32-wasi-cabal..."
    wasm32-wasi-cabal build

    # Find the built .wasm executable
    WASM_FILE=$(find dist-newstyle -name "haskell-wasm-template.wasm" -type f | head -1)
    if [ -z "$WASM_FILE" ]; then
      echo "ERROR: .wasm file not found. Did the build succeed?"
      exit 1
    fi
    echo ":: Found $WASM_FILE"

    # Copy to project root for index.html to find
    cp "$WASM_FILE" Main.wasm

    # Run GHC's post-linker to extract JSFFI metadata and generate JS glue code.
    # The post-linker reads ghc_wasm_jsffi custom sections from the .wasm file
    # and emits a JS module that provides the import namespace for instantiation.
    echo ":: Running post-linker..."
    $(wasm32-wasi-ghc --print-libdir)/post-link.mjs -i Main.wasm -o Main.js

    echo ":: Done! Main.wasm + Main.js ready."
    echo ":: Run 'just serve' to test in browser."

# Start a local dev server with live-reload
serve:
    live-server --port 9834 .

# Build and serve
dev: build serve

# Clean build artifacts
clean:
    rm -f Main.wasm Main.js
    rm -rf dist-newstyle
