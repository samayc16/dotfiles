-- Koan 02 checks. Read-only: edit Functions.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Functions

main :: IO ()
main =
  runKoans
    "Koan 02 · Functions & currying"
    [ koan "square 4" 16 (square 4)
    , koan "square (-3)" 9 (square (-3))
    , koan "add3 1 2 3" 6 (add3 1 2 3)
    , koan "addTen 5" 15 (addTen 5)
    , koan "applyTwice square 3" 81 (applyTwice square 3)
    , koan "applyTwice works on Strings too" "hey!!" (applyTwice (++ "!") "hey")
    , koan "hypotenuse 3 4" 5.0 (hypotenuse 3 4)
    ]
