-- | Koan 06 · map, filter & folds
module Folds where

squaresOfOdds :: [Int] -> [Int]
squaresOfOdds xs = undefined

-- Use foldr. Its type: (a -> b -> b) -> b -> [a] -> b
total :: [Int] -> Int
total xs = undefined

countIf :: (a -> Bool) -> [a] -> Int
countIf p xs = undefined

longestWord :: String -> String
longestWord sentence = undefined

average :: [Double] -> Maybe Double
average xs = undefined

-- >>> foldr (\x acc -> x : acc) [] [1, 2, 3]
