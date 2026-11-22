-- | Koan 03 · Lambdas, sections & composition
module Lambdas where

import Data.Char (toUpper)

doubleAll :: [Int] -> [Int]
doubleAll = undefined

incrementAll :: [Int] -> [Int]
incrementAll = undefined

shout :: String -> String
shout = undefined

lengthsOfWords :: String -> [Int]
lengthsOfWords = undefined

-- applyAll [f, g, h] x == f (g (h x))
applyAll :: [a -> a] -> a -> a
applyAll fs = undefined

-- >>> map (\n -> n * n) [1, 2, 3]
