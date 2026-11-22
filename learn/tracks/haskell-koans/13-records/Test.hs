-- Koan 13 checks. Read-only: edit Records.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Records

main :: IO ()
main =
  runKoans
    "Koan 13 · Records"
    [ koan "newMonk" (Monk "ada" White 0) (newMonk "ada")
    , koan "train adds xp" 150 (xp (train 50 (train 100 (newMonk "bo"))))
    , koan "train keeps the name" "bo" (monkName (train 5 (newMonk "bo")))
    , koan "promote White to Yellow" Yellow (belt (promote (newMonk "cy")))
    , koan "Black stays Black" Black (belt (promote (Monk "dee" Black 999)))
    , koan "ready at 100" True (ready (Monk "e" White 100))
    , koan "graduates" ["ada"] (graduates [Monk "ada" White 120, Monk "bo" Green 10])
    ]
