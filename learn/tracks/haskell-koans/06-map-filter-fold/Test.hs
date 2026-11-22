-- Koan 06 checks. Read-only: edit Folds.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Folds

main :: IO ()
main =
  runKoans
    "Koan 06 · map, filter & folds"
    [ koan "squaresOfOdds" [1, 9, 25] (squaresOfOdds [1 .. 6])
    , koan "total" 55 (total [1 .. 10])
    , koan "countIf even" 5 (countIf even [1 .. 10 :: Int])
    , koan "longestWord" "slowly" (longestWord "a monk walks slowly")
    , koan "longestWord keeps the first on ties" "cat" (longestWord "cat dog")
    , koan "longestWord of nothing" "" (longestWord "")
    , koan "average" (Just 2.5) (average [1, 2, 3, 4])
    , koan "average of empty" Nothing (average [])
    ]
