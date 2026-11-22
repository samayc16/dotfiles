-- | Koan 11 · Either
module Errors where

import Text.Read (readMaybe)

data AgeError
  = NotANumber String
  | Negative Int
  | TooOld Int
  deriving (Show, Eq)

parseAge :: String -> Either AgeError Int
parseAge s = undefined

canEnter :: String -> Either AgeError String
canEnter s = undefined

parseAll :: [String] -> Either AgeError [Int]
parseAll xs = undefined

-- >>> readMaybe "42" :: Maybe Int
