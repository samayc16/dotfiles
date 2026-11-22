-- Koan 15 checks. Read-only: edit Polymorphism.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Polymorphism

main :: IO ()
main =
  runKoans
    "Koan 15 · Polymorphism & constraints"
    [ koan "largest Int" (Just 9) (largest [3, 9, 2 :: Int])
    , koan "largest Char" (Just 'z') (largest "lazy")
    , koan "largest of nothing" Nothing (largest ([] :: [Int]))
    , koan "countOf" 3 (countOf 'a' "banana")
    , koan "joinShown" "1, 2, 3" (joinShown [1, 2, 3 :: Int])
    , koan "sumAndProduct" (10, 24) (sumAndProduct [1, 2, 3, 4 :: Int])
    , koan "clamp" [0, 5, 10] (map (clamp 0 10) [-3, 5, 42 :: Int])
    , koan "dedupe Ints" [3, 1, 2] (dedupe [3, 1, 3, 2, 1 :: Int])
    , koan "dedupe Strings" ["om", "ma"] (dedupe ["om", "ma", "om"])
    ]
