-- | Koan 24 · BOSS: The Calculator Shrine
module Calc where

import Data.Char (isDigit, isSpace)

data Expr
  = Num Int
  | Add Expr Expr
  | Sub Expr Expr
  | Mul Expr Expr
  | Div Expr Expr
  deriving (Show, Eq)

data Token = TNum Int | TPlus | TMinus | TStar | TSlash | TOpen | TClose
  deriving (Show, Eq)

-- Done for you.
tokenize :: String -> Either String [Token]
tokenize [] = Right []
tokenize s@(c : cs)
  | isSpace c = tokenize cs
  | isDigit c = let (digits, rest) = span isDigit s in (TNum (read digits) :) <$> tokenize rest
  | c == '+' = (TPlus :) <$> tokenize cs
  | c == '-' = (TMinus :) <$> tokenize cs
  | c == '*' = (TStar :) <$> tokenize cs
  | c == '/' = (TSlash :) <$> tokenize cs
  | c == '(' = (TOpen :) <$> tokenize cs
  | c == ')' = (TClose :) <$> tokenize cs
  | otherwise = Left ("unexpected character " ++ show c)

eval :: Expr -> Either String Int
eval expr = undefined

pretty :: Expr -> String
pretty expr = undefined

parseSum :: [Token] -> Either String (Expr, [Token])
parseSum tokens = undefined

parseProduct :: [Token] -> Either String (Expr, [Token])
parseProduct tokens = undefined

parseAtom :: [Token] -> Either String (Expr, [Token])
parseAtom tokens = undefined

parseExpr :: String -> Either String Expr
parseExpr input = do
  tokens <- tokenize input
  (expr, rest) <- parseSum tokens
  case rest of
    [] -> Right expr
    (t : _) -> Left ("unexpected " ++ show t)

calc :: String -> Either String Int
calc input = undefined
