-- | Koan 14 · Type classes & instances
module Classes where

import Data.List (intercalate)
import Data.Ord (comparing)

data Coin = Penny | Nickel | Dime | Quarter
  deriving (Eq, Enum, Bounded)

value :: Coin -> Int
value coin = undefined

instance Show Coin where
  show coin = undefined

instance Ord Coin where
  compare = undefined

class Describable a where
  describe :: a -> String

instance Describable Bool where
  describe b = undefined

instance Describable Coin where
  describe c = undefined

-- Any list of describable things is describable too.
instance Describable a => Describable [a] where
  describe xs = undefined
