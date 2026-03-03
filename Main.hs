-- | A minimal example of GHC's JSFFI (JavaScript Foreign Function Interface)
-- for the WebAssembly backend.
--
-- Note: No language extension is needed for JSFFI — the `foreign import javascript`
-- syntax is built into GHC when targeting the wasm32-wasi platform.
--
-- This module demonstrates:
--   1. Importing JavaScript functions into Haskell (foreign import)
--   2. Exporting Haskell functions to JavaScript (foreign export)
--   3. Using JSString for string interop between Haskell and JS
module Main where

import GHC.Wasm.Prim

-- ---------------------------------------------------------------------------
-- Foreign imports: calling JavaScript from Haskell
-- ---------------------------------------------------------------------------

-- | Log a message to the browser's developer console.
-- The $1 placeholder is replaced with the first argument at runtime.
foreign import javascript unsafe "console.log($1)"
  js_console_log :: JSString -> IO ()

-- | Set the innerHTML of document.body.
-- This is how we render content to the page from Haskell.
foreign import javascript unsafe "document.body.innerHTML = $1"
  js_set_body :: JSString -> IO ()

-- ---------------------------------------------------------------------------
-- Foreign export: exposing Haskell functions to JavaScript
-- ---------------------------------------------------------------------------

-- | Entry point called from JavaScript after the WASM module is initialized.
-- This is exported as "hs_start" (see the cabal file's ghc-options).
foreign export javascript "hs_start" main :: IO ()

-- | Our "main" function — runs in the browser!
main :: IO ()
main = do
  js_console_log (toJSString "Hello from Haskell WASM! 🚀")
  js_set_body (toJSString html)
  where
    html = mconcat
      [ "<div style='font-family: system-ui, sans-serif; max-width: 600px; "
      , "margin: 80px auto; text-align: center;'>"
      , "<h1 style='font-size: 2.5rem;'>Hello from Haskell WASM! 🚀</h1>"
      , "<p style='color: #666; font-size: 1.2rem;'>"
      , "This page is rendered by Haskell compiled to WebAssembly, "
      , "running in your browser via GHC's JSFFI."
      , "</p>"
      , "<code style='background: #f0f0f0; padding: 8px 16px; border-radius: 6px; "
      , "font-size: 0.9rem;'>"
      , "GHC WASM + JSFFI + browser_wasi_shim"
      , "</code>"
      , "</div>"
      ]
