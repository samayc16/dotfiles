-- | Koan 15 · Polymorphism & constraints
module Polymorphism where

import Data.List (intercalate)

largest :: Ord a => [a] -> Maybe a
largest [] = Nothing
largest xs = Just (maximum xs)

countOf :: Eq a => a -> [a] -> Int
countOf x xs = length (filter (== x) xs)

joinShown :: Show a => [a] -> String
joinShown xs = intercalate ", " (map show xs)

sumAndProduct :: Num a => [a] -> (a, a)
sumAndProduct xs = (sum xs, product xs)

clamp :: Ord a => a -> a -> a -> a
clamp lo hi x = max lo (min hi x)

dedupe :: Eq a => [a] -> [a]
dedupe = go []
  where
    go _ [] = []
    go seen (x : rest)
      | x `elem` seen = go seen rest
      | otherwise = x : go (x : seen) rest
