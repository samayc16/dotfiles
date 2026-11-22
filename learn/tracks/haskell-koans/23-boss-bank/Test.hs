-- Koan 23 checks. Read-only: edit Bank.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Bank
import qualified Data.Map.Strict as Map

main :: IO ()
main =
  runKoans
    "Koan 23 · BOSS: The Bank of Lambda"
    [ koan "open and deposit" (Right (Map.fromList [("ada", 100)])) (applyAll [Open "ada", Deposit "ada" 100])
    , koan "opening twice fails" (Left (AlreadyExists "ada")) (applyAll [Open "ada", Open "ada"])
    , koan "deposit into a ghost" (Left (NoSuchAccount "zed")) (applyAll [Deposit "zed" 5])
    , koan "amounts must be positive" (Left (InvalidAmount 0)) (applyAll [Open "ada", Deposit "ada" 0])
    , koan "overdraw fails with the balance" (Left (InsufficientFunds "ada" 10)) (applyAll [Open "ada", Deposit "ada" 10, Withdraw "ada" 50])
    , koan "transfer moves money" (Right (Map.fromList [("ada", 70), ("bo", 30)])) (applyAll [Open "ada", Open "bo", Deposit "ada" 100, Transfer "ada" "bo" 30])
    , koan "transfer to a ghost" (Left (NoSuchAccount "cy")) (applyAll [Open "ada", Deposit "ada" 10, Transfer "ada" "cy" 5])
    , koan "first error wins" (Left (NoSuchAccount "x")) (applyAll [Withdraw "x" 1, Open "ada", Open "ada"])
    , koan "richest" (Just ("bo", 30)) (richest (Map.fromList [("ada", 5), ("bo", 30)]))
    , koan "richest of an empty bank" Nothing (richest Map.empty)
    , koan "statement" ["ada: 120", "bo: 5"] (statement (Map.fromList [("bo", 5), ("ada", 120)]))
    ]
