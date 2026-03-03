-- | WASM entry point — bridges JavaScript and the Reflex application.
--
-- This module handles the JSaddle/WASM plumbing:
--   1. Exports 'hs_start' to JavaScript via JSFFI
--   2. Uses JSaddle.Wasm.run to set up the JSaddle environment
--   3. Delegates to 'App.app' for the actual Reflex UI
module MyMain (main) where

import App (app)
import GHC.Wasm.Prim
import Language.Javascript.JSaddle.Wasm qualified as JSaddle.Wasm

-- | Entry point exported to JavaScript as "hs_start".
-- Called from index.js after the WASM module is initialized.
-- The JSString argument is currently unused but available for
-- passing configuration from JavaScript to Haskell.
foreign export javascript "hs_start" main :: IO ()

main :: IO ()
main = JSaddle.Wasm.run app
