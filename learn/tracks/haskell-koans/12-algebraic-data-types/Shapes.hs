-- | Koan 12 · Algebraic data types
module Shapes where

data Shape
  = Circle Double -- radius
  | Rect Double Double -- width height
  | Triangle Double Double Double -- three sides
  deriving (Show, Eq)

data Light = Red | Yellow | Green
  deriving (Show, Eq, Enum, Bounded)

area :: Shape -> Double
area shape = undefined

perimeter :: Shape -> Double
perimeter shape = undefined

next :: Light -> Light
next light = undefined

largest :: [Shape] -> Maybe Shape
largest shapes = undefined
