-- Koan 14 checks. Read-only: edit Classes.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Classes
import Data.List (sort)

main :: IO ()
main =
  runKoans
    "Koan 14 · Type classes & instances"
    [ koan "show Quarter" "25¢" (show Quarter)
    , koan "show a list of coins" "[1¢,10¢]" (show [Penny, Dime])
    , koan "maximum coin" Quarter (maximum [Penny, Quarter, Dime])
    , koan "sorting coins" [Penny, Nickel, Dime] (sort [Dime, Penny, Nickel])
    , koan "describe True" "yes" (describe True)
    , koan "describe Dime" "a coin worth 10 cents" (describe Dime)
    , koan "describe a list" "yes, no" (describe [True, False])
    ]
