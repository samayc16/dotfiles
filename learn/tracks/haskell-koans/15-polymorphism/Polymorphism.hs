-- | Koan 15 · Polymorphism & constraints
module Polymorphism where

import Data.List (intercalate)

largest :: Ord a => [a] -> Maybe a
largest xs = undefined

countOf :: Eq a => a -> [a] -> Int
countOf x xs = undefined

joinShown :: Show a => [a] -> String
joinShown xs = undefined

sumAndProduct :: Num a => [a] -> (a, a)
sumAndProduct xs = undefined

clamp :: Ord a => a -> a -> a -> a
clamp lo hi x = undefined

-- No signature on purpose: let GHC infer it.
dedupe = undefined
