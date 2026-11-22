-- Koan 04 checks. Read-only: edit Patterns.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Patterns

main :: IO ()
main =
  runKoans
    "Koan 04 · Pattern matching & guards"
    [ koan "describe (-5)" "negative" (describe (-5))
    , koan "describe 0" "zero" (describe 0)
    , koan "describe 7" "small" (describe 7)
    , koan "describe 42" "large" (describe 42)
    , koan "fizzbuzz 1, 3, 5, 15" ["1", "Fizz", "Buzz", "FizzBuzz"] (map fizzbuzz [1, 3, 5, 15])
    , koan "firstOr on empty" 0 (firstOr 0 [])
    , koan "firstOr on a list" 9 (firstOr 0 [9, 8])
    , koan "vowels in haskell" "ae" (filter isVowel "haskell")
    , koan "swapPair" ("a", 1 :: Int) (swapPair (1, "a"))
    ]
