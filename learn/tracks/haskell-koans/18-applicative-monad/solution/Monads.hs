-- | Koan 18 · Applicative & Monad
module Monads where

addMaybes :: Maybe Int -> Maybe Int -> Maybe Int
addMaybes a b = (+) <$> a <*> b

userName :: Int -> Maybe String
userName uid = lookup uid [(1, "ada"), (2, "bo")]

emailFor :: String -> Maybe String
emailFor name = lookup name [("ada", "ada@lambda.dev")]

emailForUser :: Int -> Maybe String
emailForUser uid = do
  name <- userName uid
  emailFor name

safeRecip :: Double -> Maybe Double
safeRecip 0 = Nothing
safeRecip x = Just (1 / x)

safeRoot :: Double -> Maybe Double
safeRoot x
  | x < 0 = Nothing
  | otherwise = Just (sqrt x)

rootOfRecip :: Double -> Maybe Double
rootOfRecip x = safeRecip x >>= safeRoot

pairsUpTo :: Int -> [(Int, Int)]
pairsUpTo n = do
  x <- [1 .. n]
  y <- [x .. n]
  pure (x, y)
