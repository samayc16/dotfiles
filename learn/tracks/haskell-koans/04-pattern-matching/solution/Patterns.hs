-- | Koan 04 · Pattern matching & guards
module Patterns where

describe :: Int -> String
describe n
  | n < 0 = "negative"
  | n == 0 = "zero"
  | n < 10 = "small"
  | otherwise = "large"

fizzbuzz :: Int -> String
fizzbuzz n
  | n `mod` 15 == 0 = "FizzBuzz"
  | n `mod` 3 == 0 = "Fizz"
  | n `mod` 5 == 0 = "Buzz"
  | otherwise = show n

firstOr :: a -> [a] -> a
firstOr def [] = def
firstOr _ (x : _) = x

isVowel :: Char -> Bool
isVowel c = case c of
  'a' -> True
  'e' -> True
  'i' -> True
  'o' -> True
  'u' -> True
  _ -> False

swapPair :: (a, b) -> (b, a)
swapPair (a, b) = (b, a)
