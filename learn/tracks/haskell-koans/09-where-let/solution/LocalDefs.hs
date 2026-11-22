-- | Koan 09 · where & let
module LocalDefs where

bmiCategory :: Double -> Double -> String
bmiCategory weight height
  | bmi < 18.5 = "under"
  | bmi < 25 = "normal"
  | otherwise = "over"
  where
    bmi = weight / height ^ 2

roots :: Double -> Double -> Double -> Maybe (Double, Double)
roots a b c =
  let disc = b * b - 4 * a * c
      root sign = (-b + sign * sqrt disc) / (2 * a)
   in if disc < 0 then Nothing else Just (root 1, root (-1))

cylinderArea :: Double -> Double -> Double
cylinderArea r h = caps + side
  where
    caps = 2 * pi * r * r
    side = 2 * pi * r * h
