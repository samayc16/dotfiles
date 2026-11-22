-- Koan 11 checks. Read-only: edit Errors.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Errors

main :: IO ()
main =
  runKoans
    "Koan 11 · Either: errors as values"
    [ koan "parseAge 42" (Right 42) (parseAge "42")
    , koan "parseAge abc" (Left (NotANumber "abc")) (parseAge "abc")
    , koan "parseAge -3" (Left (Negative (-3))) (parseAge "-3")
    , koan "parseAge 200" (Left (TooOld 200)) (parseAge "200")
    , koan "canEnter 20" (Right "welcome") (canEnter "20")
    , koan "canEnter 12" (Right "too young") (canEnter "12")
    , koan "canEnter x" (Left (NotANumber "x")) (canEnter "x")
    , koan "parseAll ok" (Right [1, 2]) (parseAll ["1", "2"])
    , koan "parseAll: first error wins" (Left (NotANumber "x")) (parseAll ["1", "x", "-1"])
    ]
