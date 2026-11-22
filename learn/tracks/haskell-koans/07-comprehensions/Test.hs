-- Koan 07 checks. Read-only: edit Comprehensions.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Comprehensions
import Data.List (sort)

main :: IO ()
main =
  runKoans
    "Koan 07 · List comprehensions & ranges"
    [ koan "evensUpTo 10" [2, 4, 6, 8, 10] (evensUpTo 10)
    , koan "pythagorean 20 (sorted)" [(3, 4, 5), (5, 12, 13), (6, 8, 10), (8, 15, 17), (9, 12, 15), (12, 16, 20)] (sort (pythagorean 20))
    , koan "grid 2 3" [(0, 0), (0, 1), (0, 2), (1, 0), (1, 1), (1, 2)] (grid 2 3)
    , koan "lettersFrom 'w'" "wxyz" (lettersFrom 'w')
    , koan "multiplicationTable 3" [[1, 2, 3], [2, 4, 6], [3, 6, 9]] (multiplicationTable 3)
    ]
