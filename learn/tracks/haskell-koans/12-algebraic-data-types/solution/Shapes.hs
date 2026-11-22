-- | Koan 12 · Algebraic data types
module Shapes where

import Data.List (maximumBy)
import Data.Ord (comparing)

data Shape
  = Circle Double
  | Rect Double Double
  | Triangle Double Double Double
  deriving (Show, Eq)

data Light = Red | Yellow | Green
  deriving (Show, Eq, Enum, Bounded)

area :: Shape -> Double
area (Circle r) = pi * r * r
area (Rect w h) = w * h
area (Triangle a b c) = sqrt (s * (s - a) * (s - b) * (s - c))
  where
    s = (a + b + c) / 2

perimeter :: Shape -> Double
perimeter (Circle r) = 2 * pi * r
perimeter (Rect w h) = 2 * (w + h)
perimeter (Triangle a b c) = a + b + c

next :: Light -> Light
next Red = Green
next Green = Yellow
next Yellow = Red

largest :: [Shape] -> Maybe Shape
largest [] = Nothing
largest shapes = Just (maximumBy (comparing area) shapes)
