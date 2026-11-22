-- | Koan 19 · IO & do-notation
module Effects where

import Control.Monad (forM_, when)
import Data.Char (toUpper)

countdown :: Int -> IO ()
countdown n = do
  forM_ [n, n - 1 .. 1] print
  putStrLn "liftoff!"

greetAll :: [String] -> IO Int
greetAll names = do
  forM_ names $ \name -> putStrLn ("hello, " ++ name)
  pure (length names)

sumActions :: [IO Int] -> IO Int
sumActions actions = do
  values <- sequence actions
  pure (sum values)

whenLoud :: Bool -> String -> IO ()
whenLoud flag msg = when flag (putStrLn (map toUpper msg))

main :: IO ()
main = do
  countdown 3
  n <- greetAll ["ada", "bo"]
  print n
