-- | Koan 07 · List comprehensions & ranges
module Comprehensions where

evensUpTo :: Int -> [Int]
evensUpTo n = [x | x <- [1 .. n], even x]

pythagorean :: Int -> [(Int, Int, Int)]
pythagorean n = [(a, b, c) | c <- [1 .. n], b <- [1 .. c], a <- [1 .. b], a * a + b * b == c * c]

grid :: Int -> Int -> [(Int, Int)]
grid r c = [(row, col) | row <- [0 .. r - 1], col <- [0 .. c - 1]]

lettersFrom :: Char -> String
lettersFrom c = [c .. 'z']

multiplicationTable :: Int -> [[Int]]
multiplicationTable n = [[row * col | col <- [1 .. n]] | row <- [1 .. n]]
