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
newMonk name = Monk {monkName = name, belt = White, xp = 0}

train :: Int -> Monk -> Monk
train n m = m {xp = xp m + n}

promote :: Monk -> Monk
promote m
  | belt m == maxBound = m
  | otherwise = m {belt = succ (belt m)}

ready :: Monk -> Bool
ready m = xp m >= 100

graduates :: [Monk] -> [String]
graduates ms = [monkName m | m <- ms, ready m]
