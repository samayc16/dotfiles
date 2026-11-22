-- | Koan 23 · BOSS: The Bank of Lambda
module Bank where

import Control.Monad (foldM, when)
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

balanceOf :: Accounts -> String -> Either BankError Int
balanceOf accounts name = maybe (Left (NoSuchAccount name)) Right (Map.lookup name accounts)

positive :: Int -> Either BankError ()
positive amt = when (amt <= 0) (Left (InvalidAmount amt))

apply :: Accounts -> Txn -> Either BankError Accounts
apply accounts (Open name)
  | Map.member name accounts = Left (AlreadyExists name)
  | otherwise = Right (Map.insert name 0 accounts)
apply accounts (Deposit name amt) = do
  positive amt
  bal <- balanceOf accounts name
  pure (Map.insert name (bal + amt) accounts)
apply accounts (Withdraw name amt) = do
  positive amt
  bal <- balanceOf accounts name
  when (bal < amt) (Left (InsufficientFunds name bal))
  pure (Map.insert name (bal - amt) accounts)
apply accounts (Transfer from to amt) = do
  positive amt
  fromBal <- balanceOf accounts from
  toBal <- balanceOf accounts to
  when (fromBal < amt) (Left (InsufficientFunds from fromBal))
  pure (Map.insert to (toBal + amt) (Map.insert from (fromBal - amt) accounts))

applyAll :: [Txn] -> Either BankError Accounts
applyAll = foldM apply Map.empty

richest :: Accounts -> Maybe (String, Int)
richest accounts
  | Map.null accounts = Nothing
  | otherwise = Just (maximumBy (comparing snd) (Map.toList accounts))

statement :: Accounts -> [String]
statement accounts = [name ++ ": " ++ show bal | (name, bal) <- Map.toAscList accounts]
