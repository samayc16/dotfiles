-- | Koan 02 · Functions & currying
module Functions where

square :: Int -> Int
square x = undefined

add3 :: Int -> Int -> Int -> Int
add3 a b c = undefined

-- Partial application: give add3 two of its three arguments.
addTen :: Int -> Int
addTen = undefined

-- Functions are values: f is a function you can call twice.
applyTwice :: (a -> a) -> a -> a
applyTwice f x = undefined

hypotenuse :: Double -> Double -> Double
hypotenuse a b = undefined

-- >>> :t add3 1
