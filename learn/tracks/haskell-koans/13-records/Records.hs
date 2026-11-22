-- | Koan 13 · Records
module Records where

data Belt = White | Yellow | Green | Black
  deriving (Show, Eq, Ord, Enum, Bounded)

data Monk = Monk
  { monkName :: String
  , belt :: Belt
  , xp :: Int
  }
  deriving (Show, Eq)

newMonk :: String -> Monk
newMonk name = undefined

train :: Int -> Monk -> Monk
train n m = undefined

promote :: Monk -> Monk
promote m = undefined

ready :: Monk -> Bool
ready m = undefined

graduates :: [Monk] -> [String]
graduates ms = undefined
