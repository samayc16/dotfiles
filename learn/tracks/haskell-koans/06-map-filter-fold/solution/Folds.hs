-- | Koan 06 · map, filter & folds
module Folds where

squaresOfOdds :: [Int] -> [Int]
squaresOfOdds xs = map (^ 2) (filter odd xs)

total :: [Int] -> Int
total xs = foldr (+) 0 xs

countIf :: (a -> Bool) -> [a] -> Int
countIf p xs = length (filter p xs)

longestWord :: String -> String
longestWord sentence = foldl pick "" (words sentence)
  where
    pick best w = if length w > length best then w else best

average :: [Double] -> Maybe Double
average [] = Nothing
average xs = Just (sum xs / fromIntegral (length xs))
