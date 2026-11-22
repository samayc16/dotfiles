-- | Koan 02 · Functions & currying
module Functions where

square :: Int -> Int
square x = x * x

add3 :: Int -> Int -> Int -> Int
add3 a b c = a + b + c

addTen :: Int -> Int
addTen = add3 10 0

applyTwice :: (a -> a) -> a -> a
applyTwice f x = f (f x)

hypotenuse :: Double -> Double -> Double
hypotenuse a b = sqrt (a * a + b * b)
