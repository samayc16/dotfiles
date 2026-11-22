-- | Koan 17 · Functor
module Functors where

data Box a = Box a deriving (Show, Eq)

data Pair a = Pair a a deriving (Show, Eq)

data Tree a = Leaf | Node (Tree a) a (Tree a) deriving (Show, Eq)

instance Functor Box where
  fmap f box = undefined

instance Functor Pair where
  fmap f pair = undefined

instance Functor Tree where
  fmap f tree = undefined

incAll :: Functor f => f Int -> f Int
incAll = undefined

lengths :: Maybe String -> Maybe Int
lengths m = undefined
