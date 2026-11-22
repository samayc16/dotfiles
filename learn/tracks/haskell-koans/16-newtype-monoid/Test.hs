-- Koan 16 checks. Read-only: edit Monoids.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Monoids

main :: IO ()
main =
  runKoans
    "Koan 16 · newtype, Semigroup & Monoid"
    [ koan "Score adds" (Score 7) (Score 3 <> Score 4)
    , koan "mempty Score" (Score 0) (mempty :: Score)
    , koan "totalScore" (Score 6) (totalScore [Score 1, Score 2, Score 3])
    , koan "totalScore of nothing" (Score 0) (totalScore [])
    , koan "MaxScore keeps the best" (MaxScore 9) (MaxScore 3 <> MaxScore 9)
    , koan "best of nothing" Nothing (best [])
    , koan "best" (Just (MaxScore 5)) (best [MaxScore 2, MaxScore 5, MaxScore 1])
    , koan "mkName trims" (Just (Name "Ada")) (mkName "  Ada ")
    , koan "mkName rejects blanks" Nothing (mkName "   ")
    ]
