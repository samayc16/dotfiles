-- Koan 17 checks. Read-only: edit Functors.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Functors

main :: IO ()
main =
  runKoans
    "Koan 17 · Functor: mapping inside a box"
    [ koan "fmap over Box" (Box 2) (fmap (+ 1) (Box 1))
    , koan "fmap over Pair" (Pair "1" "2") (fmap show (Pair 1 2 :: Pair Int))
    , koan "fmap over Tree" (Node Leaf 6 (Node Leaf 8 Leaf)) (fmap (* 2) (Node Leaf 3 (Node Leaf 4 Leaf)))
    , koan "incAll Maybe" (Just 2) (incAll (Just 1))
    , koan "incAll list" [2, 3] (incAll [1, 2])
    , koan "incAll Box" (Box 10) (incAll (Box 9))
    , koan "lengths Just" (Just 3) (lengths (Just "abc"))
    , koan "lengths Nothing" Nothing (lengths Nothing)
    ]
