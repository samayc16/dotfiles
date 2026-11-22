-- Koan 01 checks. Read-only: edit Expressions.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Expressions

main :: IO ()
main =
  runKoans
    "Koan 01 · Expressions & types"
    [ koan "secondsPerDay is 86400" 86400 secondsPerDay
    , koan "average of 3, 4, 8 is 5.0" 5.0 average
    , koan "greeting" "Hello, apprentice" greeting
    , koan "ten is even" True tenIsEven
    , koan "17 mod 5" 2 remainder
    , koan "half of seven" 3.5 halfOfSeven
    ]
