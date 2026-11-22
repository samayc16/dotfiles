-- Koan 08 checks. Read-only: edit Tuples.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Tuples

main :: IO ()
main =
  runKoans
    "Koan 08 · Tuples & zip"
    [ koan "pairUp" [(1, 'a'), (2, 'b')] (pairUp [1, 2 :: Int] "ab")
    , koan "dotProduct" 32 (dotProduct [1, 2, 3] [4, 5, 6])
    , koan "indexed starts at 1" [(1, 'a'), (2, 'b')] (indexed "ab")
    , koan "ageOf bo" (Just 7) (ageOf "bo" [("ada", 36), ("bo", 7)])
    , koan "ageOf a stranger" Nothing (ageOf "cy" [("ada", 36)])
    , koan "splitPairs" ([1, 2 :: Int], "ab") (splitPairs [(1, 'a'), (2, 'b')])
    ]
