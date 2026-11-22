-- Koan 09 checks. Read-only: edit LocalDefs.hs in your workspace instead.
module Main (main) where

import KoanCheck
import LocalDefs

main :: IO ()
main =
  runKoans
    "Koan 09 · where & let"
    [ koan "bmi under" "under" (bmiCategory 50 1.8)
    , koan "bmi normal" "normal" (bmiCategory 70 1.75)
    , koan "bmi over" "over" (bmiCategory 95 1.7)
    , koan "roots of x^2 - 3x + 2" (Just (2.0, 1.0)) (roots 1 (-3) 2)
    , koan "no real roots" Nothing (roots 1 0 1)
    , koanWith "cylinderArea 1 1 is 4π" "a value within 1e-9 of 12.566" (\x -> abs (x - 4 * pi) < 1e-9) (cylinderArea 1 1)
    ]
