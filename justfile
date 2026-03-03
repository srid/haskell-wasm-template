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

    # Copy to project root as bin.wasm (what index.js expects)
    cp "$WASM_FILE" bin.wasm

    # Run GHC's post-linker to extract JSFFI metadata and generate JS glue.
    # This reads ghc_wasm_jsffi custom sections from the .wasm and emits
    # a JS module providing the import namespace for WASM instantiation.
    echo ":: Running post-linker..."
    $(wasm32-wasi-ghc --print-libdir)/post-link.mjs \
        --input bin.wasm --output ghc_wasm_jsffi.js

    echo ":: Done! bin.wasm + ghc_wasm_jsffi.js ready."
    echo ":: Run 'just serve' to test in browser."

# Start a local dev server with live-reload
serve:
    live-server --port 9834 .

# Build and serve
dev: build serve

# Update cabal package index (needed on first build)
update:
    wasm32-wasi-cabal update

# Clean build artifacts
clean:
    rm -f bin.wasm ghc_wasm_jsffi.js
    rm -rf dist-newstyle
