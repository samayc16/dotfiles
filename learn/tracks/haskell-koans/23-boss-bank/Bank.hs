-- | Koan 23 · BOSS: The Bank of Lambda
module Bank where

import Control.Monad (foldM)
import Data.List (maximumBy)
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Data.Ord (comparing)

type Accounts = Map String Int

data Txn
  = Open String
  | Deposit String Int
  | Withdraw String Int
  | Transfer String String Int
  deriving (Show, Eq)

data BankError
  = NoSuchAccount String
  | AlreadyExists String
  | InsufficientFunds String Int
  | InvalidAmount Int
  deriving (Show, Eq)

apply :: Accounts -> Txn -> Either BankError Accounts
apply accounts txn = undefined

applyAll :: [Txn] -> Either BankError Accounts
applyAll txns = undefined

richest :: Accounts -> Maybe (String, Int)
richest accounts = undefined

statement :: Accounts -> [String]
statement accounts = undefined
