-- | Koan 20 · Laziness & infinite lists
module Lazy where

naturals :: [Integer]
naturals = [0 ..]

firstSquaresOver :: Integer -> [Integer]
firstSquaresOver n = take 5 (filter (> n) (map (^ 2) naturals))

fibs :: [Integer]
fibs = 0 : 1 : zipWith (+) fibs (tail fibs)

primes :: [Int]
primes = sieve [2 ..]
  where
    sieve (p : xs) = p : sieve [x | x <- xs, x `mod` p /= 0]
    sieve [] = []

collatz :: Int -> [Int]
collatz n = takeWhile (/= 1) (iterate step n) ++ [1]
  where
    step k = if even k then k `div` 2 else 3 * k + 1
