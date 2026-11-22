-- Koan 05 checks. Read-only: edit Recursion.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Recursion

main :: IO ()
main =
  runKoans
    "Koan 05 · Recursion on lists"
    [ koan "myLength" 4 (myLength "zen!")
    , koan "myLength []" 0 (myLength ([] :: [Int]))
    , koan "mySum" 15 (mySum [1 .. 5])
    , koan "myReverse" "olleh" (myReverse "hello")
    , koan "myElem finds it" True (myElem 3 [1, 2, 3])
    , koan "myElem misses" False (myElem 'z' "monk")
    , koan "countdown 3" [3, 2, 1] (countdown 3)
    , koan "countdown 0" [] (countdown 0)
    , koan "myZip stops at the shorter list" [(1, 'a'), (2, 'b')] (myZip [1, 2, 3 :: Int] "ab")
    ]
