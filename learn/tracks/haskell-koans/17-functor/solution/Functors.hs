-- | Koan 17 · Functor
module Functors where

data Box a = Box a deriving (Show, Eq)

data Pair a = Pair a a deriving (Show, Eq)

data Tree a = Leaf | Node (Tree a) a (Tree a) deriving (Show, Eq)

instance Functor Box where
  fmap f (Box a) = Box (f a)

instance Functor Pair where
  fmap f (Pair a b) = Pair (f a) (f b)

instance Functor Tree where
  fmap _ Leaf = Leaf
  fmap f (Node l x r) = Node (fmap f l) (f x) (fmap f r)

incAll :: Functor f => f Int -> f Int
incAll = fmap (+ 1)

lengths :: Maybe String -> Maybe Int
lengths m = length <$> m
