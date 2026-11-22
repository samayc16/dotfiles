-- Koan 20 checks. Read-only: edit Lazy.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Lazy

main :: IO ()
main =
  runKoans
    "Koan 20 · Laziness & infinite lists"
    [ koan "take 5 naturals" [0, 1, 2, 3, 4] (take 5 naturals)
    , koan "firstSquaresOver 10" [16, 25, 36, 49, 64] (firstSquaresOver 10)
    , koan "first 10 fibs" [0, 1, 1, 2, 3, 5, 8, 13, 21, 34] (take 10 fibs)
    , koan "the 90th fib" 2880067194370816120 (fibs !! 90)
    , koan "first 10 primes" [2, 3, 5, 7, 11, 13, 17, 19, 23, 29] (take 10 primes)
    , koan "the 200th prime" 1223 (primes !! 199)
    , koan "collatz 6" [6, 3, 10, 5, 16, 8, 4, 2, 1] (collatz 6)
    ]
