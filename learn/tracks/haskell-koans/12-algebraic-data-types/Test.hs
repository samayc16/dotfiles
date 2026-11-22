-- Koan 12 checks. Read-only: edit Shapes.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Shapes

main :: IO ()
main =
  runKoans
    "Koan 12 · Algebraic data types"
    [ koan "area of a rectangle" 6 (area (Rect 2 3))
    , koanWith "area of a unit circle" "π" (\x -> abs (x - pi) < 1e-9) (area (Circle 1))
    , koan "area of a 3-4-5 triangle" 6 (area (Triangle 3 4 5))
    , koan "perimeter of a triangle" 12 (perimeter (Triangle 3 4 5))
    , koanWith "perimeter of a unit circle" "2π" (\x -> abs (x - 2 * pi) < 1e-9) (perimeter (Circle 1))
    , koan "traffic lights cycle" [Green, Yellow, Red] (map next [Red, Green, Yellow])
    , koan "largest of nothing" Nothing (largest [])
    , koan "largest shape" (Just (Circle 1)) (largest [Rect 1 1, Circle 1, Rect 2 1])
    ]
