-- | Koan 16 · newtype, Semigroup & Monoid
module Monoids where

import Data.Char (isSpace)
import Data.List (dropWhileEnd)

newtype Score = Score Int deriving (Show, Eq)

instance Semigroup Score where
  Score a <> Score b = Score (a + b)

instance Monoid Score where
  mempty = Score 0

newtype MaxScore = MaxScore Int deriving (Show, Eq)

instance Semigroup MaxScore where
  MaxScore a <> MaxScore b = MaxScore (max a b)

totalScore :: [Score] -> Score
totalScore = mconcat

best :: [MaxScore] -> Maybe MaxScore
best [] = Nothing
best scores = Just (foldr1 (<>) scores)

newtype Name = Name String deriving (Show, Eq)

mkName :: String -> Maybe Name
mkName raw
  | null trimmed = Nothing
  | otherwise = Just (Name trimmed)
  where
    trimmed = dropWhileEnd isSpace (dropWhile isSpace raw)
