-- Koan 18 checks. Read-only: edit Monads.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Monads

main :: IO ()
main =
  runKoans
    "Koan 18 · Applicative & Monad with Maybe"
    [ koan "addMaybes" (Just 3) (addMaybes (Just 1) (Just 2))
    , koan "addMaybes with a gap" Nothing (addMaybes Nothing (Just 2))
    , koan "emailForUser 1" (Just "ada@lambda.dev") (emailForUser 1)
    , koan "emailForUser 2 (no email)" Nothing (emailForUser 2)
    , koan "emailForUser 99 (no user)" Nothing (emailForUser 99)
    , koan "rootOfRecip 4" (Just 0.5) (rootOfRecip 4)
    , koan "rootOfRecip 0" Nothing (rootOfRecip 0)
    , koan "rootOfRecip (-4)" Nothing (rootOfRecip (-4))
    , koan "pairsUpTo 2" [(1, 1), (1, 2), (2, 2)] (pairsUpTo 2)
    ]
