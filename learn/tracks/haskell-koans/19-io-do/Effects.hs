-- | Koan 19 · IO & do-notation
module Effects where

import Control.Monad (forM_, when)
import Data.Char (toUpper)

countdown :: Int -> IO ()
countdown n = undefined

greetAll :: [String] -> IO Int
greetAll names = undefined

sumActions :: [IO Int] -> IO Int
sumActions actions = undefined

whenLoud :: Bool -> String -> IO ()
whenLoud flag msg = undefined

-- Run the whole thing with <leader>rr (runghc runs `main`):
main :: IO ()
main = do
  countdown 3
  n <- greetAll ["ada", "bo"]
  print n
