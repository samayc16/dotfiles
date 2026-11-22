-- | Koan 10 · Maybe
module Maybes where

import Data.Maybe (fromMaybe)

menu :: [(String, Double)]
menu = [("tea", 3.5), ("mochi", 4.0), ("ramen", 12.0)]

safeDiv :: Int -> Int -> Maybe Int
safeDiv a b = undefined

safeHead :: [a] -> Maybe a
safeHead xs = undefined

priceOf :: String -> Maybe Double
priceOf item = undefined

priceOrZero :: String -> Double
priceOrZero item = undefined

-- Nothing if any item is not on the menu.
totalPrice :: [String] -> Maybe Double
totalPrice items = undefined
