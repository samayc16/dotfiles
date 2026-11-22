-- | Koan 10 · Maybe
module Maybes where

import Data.Maybe (fromMaybe)

menu :: [(String, Double)]
menu = [("tea", 3.5), ("mochi", 4.0), ("ramen", 12.0)]

safeDiv :: Int -> Int -> Maybe Int
safeDiv _ 0 = Nothing
safeDiv a b = Just (a `div` b)

safeHead :: [a] -> Maybe a
safeHead [] = Nothing
safeHead (x : _) = Just x

priceOf :: String -> Maybe Double
priceOf item = lookup item menu

priceOrZero :: String -> Double
priceOrZero item = fromMaybe 0 (priceOf item)

totalPrice :: [String] -> Maybe Double
totalPrice [] = Just 0
totalPrice (item : rest) = case (priceOf item, totalPrice rest) of
  (Just p, Just t) -> Just (p + t)
  _ -> Nothing
