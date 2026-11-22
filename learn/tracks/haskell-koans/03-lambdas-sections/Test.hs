-- Koan 03 checks. Read-only: edit Lambdas.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Lambdas

main :: IO ()
main =
  runKoans
    "Koan 03 · Lambdas, sections & composition"
    [ koan "doubleAll" [2, 4, 6] (doubleAll [1, 2, 3])
    , koan "incrementAll" [1, 10] (incrementAll [0, 9])
    , koan "shout" "OM!" (shout "om")
    , koan "lengthsOfWords" [3, 5, 5, 3] (lengthsOfWords "the quick brown fox")
    , koan "applyAll composes right to left" 11 (applyAll [(+ 1), (* 2)] 5)
    , koan "applyAll of nothing is identity" 7 (applyAll [] 7)
    ]
