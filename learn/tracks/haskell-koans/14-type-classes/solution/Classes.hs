-- | Koan 14 · Type classes & instances
module Classes where

import Data.List (intercalate)
import Data.Ord (comparing)

data Coin = Penny | Nickel | Dime | Quarter
  deriving (Eq, Enum, Bounded)

value :: Coin -> Int
value Penny = 1
value Nickel = 5
value Dime = 10
value Quarter = 25

instance Show Coin where
  show coin = show (value coin) ++ "¢"

instance Ord Coin where
  compare = comparing value

class Describable a where
  describe :: a -> String

instance Describable Bool where
  describe True = "yes"
  describe False = "no"

instance Describable Coin where
  describe c = "a coin worth " ++ show (value c) ++ " cents"

instance Describable a => Describable [a] where
  describe xs = intercalate ", " (map describe xs)
