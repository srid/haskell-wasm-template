-- | A simple Reflex FRP application demonstrating reactive DOM programming.
--
-- This shows core Reflex concepts:
--   - 'Event' : discrete occurrences (button clicks)
--   - 'Dynamic' : time-varying values (the counter)
--   - 'foldDyn' : accumulating events into state
--   - 'dynText' : rendering dynamic values into the DOM
module App (app) where

import Data.Text (Text)
import Data.Text qualified as T
import Language.Javascript.JSaddle (JSM)
import Reflex.Dom.Core

-- | The main Reflex widget — a simple click counter.
app :: JSM ()
app = mainWidget $ el "div" $ do
  el "h1" $ text "Haskell WASM + Reflex 🚀"
  el "p" $ text "A reactive counter built with Reflex FRP, compiled to WebAssembly."

  -- Create a button; 'button' returns an Event that fires on each click
  clickEvt <- button "Click me!"

  -- Accumulate clicks into a Dynamic counter using foldDyn:
  --   foldDyn f initial event
  --   Each time 'clickEvt' fires, apply 'f' to update the counter
  count <- foldDyn (\_ n -> n + 1) (0 :: Int) clickEvt

  -- Display the dynamic count
  el "p" $ do
    text "Count: "
    dynText $ T.pack . show <$> count
