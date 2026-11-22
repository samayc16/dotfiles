-- Koan 19 checks. Read-only: edit Effects.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Effects hiding (main)

main :: IO ()
main =
  runKoans
    "Koan 19 · IO & do-notation"
    [ koanOutput "countdown 3" "3\n2\n1\nliftoff!\n" (countdown 3)
    , koanIO "greetAll prints and counts" ("hello, ada\nhello, bo\n", 2) (captureOutput (greetAll ["ada", "bo"]))
    , koanIO "sumActions" 6 (sumActions [pure 1, pure 2, pure 3])
    , koanOutput "whenLoud True" "OM\n" (whenLoud True "om")
    , koanOutput "whenLoud False is silent" "" (whenLoud False "om")
    ]
