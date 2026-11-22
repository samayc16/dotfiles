-- | Koan 03 · Lambdas, sections & composition
module Lambdas where

import Data.Char (toUpper)

doubleAll :: [Int] -> [Int]
doubleAll = map (* 2)

incrementAll :: [Int] -> [Int]
incrementAll = map (\x -> x + 1)

shout :: String -> String
shout = (++ "!") . map toUpper

lengthsOfWords :: String -> [Int]
lengthsOfWords = map length . words

applyAll :: [a -> a] -> a -> a
applyAll fs = foldr (.) id fs
