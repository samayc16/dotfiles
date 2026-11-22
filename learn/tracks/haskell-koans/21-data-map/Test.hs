-- Koan 21 checks. Read-only: edit WordCount.hs in your workspace instead.
module Main (main) where

import KoanCheck
import WordCount
import qualified Data.Map.Strict as Map

main :: IO ()
main =
  runKoans
    "Koan 21 · Data.Map: dictionaries"
    [ koan "wordFreq" (Map.fromList [("cat", 1), ("hat", 1), ("the", 2)]) (wordFreq "The cat. the hat!")
    , koan "topN 2" [("c", 3), ("b", 2)] (topN 2 (wordFreq "b a b c c c"))
    , koan "topN breaks ties alphabetically" [("a", 1), ("b", 1)] (topN 2 (wordFreq "b a"))
    , koan "inventory sums duplicates" (Map.fromList [("mochi", 1), ("tea", 5)]) (inventory [("tea", 2), ("mochi", 1), ("tea", 3)])
    , koan "restock existing" (Map.fromList [("tea", 5)]) (restock "tea" 4 (Map.fromList [("tea", 1)]))
    , koan "restock new" (Map.fromList [("rice", 2)]) (restock "rice" 2 Map.empty)
    , koan "countOf missing" 0 (countOf "x" Map.empty)
    ]
