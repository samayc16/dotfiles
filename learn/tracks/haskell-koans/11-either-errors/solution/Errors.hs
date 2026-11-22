-- | Koan 11 · Either
module Errors where

import Text.Read (readMaybe)

data AgeError
  = NotANumber String
  | Negative Int
  | TooOld Int
  deriving (Show, Eq)

parseAge :: String -> Either AgeError Int
parseAge s = case readMaybe s of
  Nothing -> Left (NotANumber s)
  Just n
    | n < 0 -> Left (Negative n)
    | n > 150 -> Left (TooOld n)
    | otherwise -> Right n

canEnter :: String -> Either AgeError String
canEnter s = do
  age <- parseAge s
  pure (if age >= 18 then "welcome" else "too young")

parseAll :: [String] -> Either AgeError [Int]
parseAll xs = mapM parseAge xs
