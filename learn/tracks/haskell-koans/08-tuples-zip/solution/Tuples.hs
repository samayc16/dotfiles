-- | Koan 08 · Tuples & zip
module Tuples where

pairUp :: [a] -> [b] -> [(a, b)]
pairUp xs ys = zip xs ys

dotProduct :: [Int] -> [Int] -> Int
dotProduct xs ys = sum (zipWith (*) xs ys)

indexed :: [a] -> [(Int, a)]
indexed xs = zip [1 ..] xs

ageOf :: String -> [(String, Int)] -> Maybe Int
ageOf name people = lookup name people

splitPairs :: [(a, b)] -> ([a], [b])
splitPairs pairs = unzip pairs
