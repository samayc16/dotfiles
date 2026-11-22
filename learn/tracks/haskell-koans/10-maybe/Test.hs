-- Koan 10 checks. Read-only: edit Maybes.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Maybes

main :: IO ()
main =
  runKoans
    "Koan 10 · Maybe: values that might be missing"
    [ koan "safeDiv 10 2" (Just 5) (safeDiv 10 2)
    , koan "safeDiv by zero" Nothing (safeDiv 1 0)
    , koan "safeHead empty" Nothing (safeHead "")
    , koan "safeHead [7]" (Just 7) (safeHead [7 :: Int])
    , koan "priceOf tea" (Just 3.5) (priceOf "tea")
    , koan "priceOf pizza" Nothing (priceOf "pizza")
    , koan "priceOrZero pizza" 0 (priceOrZero "pizza")
    , koan "totalPrice of a real order" (Just 7.5) (totalPrice ["tea", "mochi"])
    , koan "totalPrice with an unknown item" Nothing (totalPrice ["tea", "pizza"])
    ]
