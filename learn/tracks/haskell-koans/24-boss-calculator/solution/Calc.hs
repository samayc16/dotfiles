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
eval (Num n) = Right n
eval (Add a b) = (+) <$> eval a <*> eval b
eval (Sub a b) = (-) <$> eval a <*> eval b
eval (Mul a b) = (*) <$> eval a <*> eval b
eval (Div a b) = do
  x <- eval a
  y <- eval b
  if y == 0 then Left "division by zero" else Right (x `div` y)

pretty :: Expr -> String
pretty (Num n) = show n
pretty (Add a b) = binary "+" a b
pretty (Sub a b) = binary "-" a b
pretty (Mul a b) = binary "*" a b
pretty (Div a b) = binary "/" a b

binary :: String -> Expr -> Expr -> String
binary op a b = "(" ++ pretty a ++ " " ++ op ++ " " ++ pretty b ++ ")"

parseSum :: [Token] -> Either String (Expr, [Token])
parseSum tokens = parseProduct tokens >>= uncurry go
  where
    go lhs (TPlus : rest) = parseProduct rest >>= \(rhs, rest') -> go (Add lhs rhs) rest'
    go lhs (TMinus : rest) = parseProduct rest >>= \(rhs, rest') -> go (Sub lhs rhs) rest'
    go lhs rest = Right (lhs, rest)

parseProduct :: [Token] -> Either String (Expr, [Token])
parseProduct tokens = parseAtom tokens >>= uncurry go
  where
    go lhs (TStar : rest) = parseAtom rest >>= \(rhs, rest') -> go (Mul lhs rhs) rest'
    go lhs (TSlash : rest) = parseAtom rest >>= \(rhs, rest') -> go (Div lhs rhs) rest'
    go lhs rest = Right (lhs, rest)

parseAtom :: [Token] -> Either String (Expr, [Token])
parseAtom (TNum n : rest) = Right (Num n, rest)
parseAtom (TOpen : rest) = do
  (inner, rest') <- parseSum rest
  case rest' of
    (TClose : rest'') -> Right (inner, rest'')
    _ -> Left "expected )"
parseAtom (t : _) = Left ("unexpected " ++ show t)
parseAtom [] = Left "unexpected end of input"

parseExpr :: String -> Either String Expr
parseExpr input = do
  tokens <- tokenize input
  (expr, rest) <- parseSum tokens
  case rest of
    [] -> Right expr
    (t : _) -> Left ("unexpected " ++ show t)

calc :: String -> Either String Int
calc input = parseExpr input >>= eval
