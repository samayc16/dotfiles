-- | Koan 16 · newtype, Semigroup & Monoid
module Monoids where

import Data.Char (isSpace)
import Data.List (dropWhileEnd)

newtype Score = Score Int deriving (Show, Eq)

instance Semigroup Score where
  Score a <> Score b = undefined

instance Monoid Score where
  mempty = undefined

newtype MaxScore = MaxScore Int deriving (Show, Eq)

instance Semigroup MaxScore where
  MaxScore a <> MaxScore b = undefined

totalScore :: [Score] -> Score
totalScore = undefined

best :: [MaxScore] -> Maybe MaxScore
best scores = undefined

newtype Name = Name String deriving (Show, Eq)

mkName :: String -> Maybe Name
mkName raw = undefined
