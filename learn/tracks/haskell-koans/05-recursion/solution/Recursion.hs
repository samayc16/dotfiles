-- | Koan 05 · Recursion on lists
module Recursion where

myLength :: [a] -> Int
myLength [] = 0
myLength (_ : rest) = 1 + myLength rest

mySum :: [Int] -> Int
mySum [] = 0
mySum (x : rest) = x + mySum rest

myReverse :: [a] -> [a]
myReverse [] = []
myReverse (x : rest) = myReverse rest ++ [x]

myElem :: Eq a => a -> [a] -> Bool
myElem _ [] = False
myElem y (x : rest) = x == y || myElem y rest

countdown :: Int -> [Int]
countdown n
  | n <= 0 = []
  | otherwise = n : countdown (n - 1)

myZip :: [a] -> [b] -> [(a, b)]
myZip (x : xs) (y : ys) = (x, y) : myZip xs ys
myZip _ _ = []
