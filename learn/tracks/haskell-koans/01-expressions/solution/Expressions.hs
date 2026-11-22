-- | Koan 01 · Expressions & types
module Expressions where

secondsPerDay :: Int
secondsPerDay = 24 * 60 * 60

average :: Double
average = (3.0 + 4.0 + 8.0) / 3

greeting :: String
greeting = "Hello, " ++ "apprentice"

tenIsEven :: Bool
tenIsEven = even 10

remainder :: Int
remainder = 17 `mod` 5

halfOfSeven :: Double
halfOfSeven = halve 7
  where
    halve :: Int -> Double
    halve n = fromIntegral n / 2
