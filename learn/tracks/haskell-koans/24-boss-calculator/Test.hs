-- Koan 24 checks. Read-only: edit Calc.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Calc

main :: IO ()
main =
  runKoans
    "Koan 24 · BOSS: The Calculator Shrine"
    [ koan "eval" (Right 7) (eval (Add (Num 1) (Mul (Num 2) (Num 3))))
    , koan "eval division by zero" (Left "division by zero") (eval (Div (Num 1) (Num 0)))
    , koan "pretty" "(1 + (2 * 3))" (pretty (Add (Num 1) (Mul (Num 2) (Num 3))))
    , koan "precedence: * binds tighter" (Right (Add (Num 1) (Mul (Num 2) (Num 3)))) (parseExpr "1 + 2 * 3")
    , koan "left associativity" (Right (Sub (Sub (Num 10) (Num 4)) (Num 3))) (parseExpr "10 - 4 - 3")
    , koan "parentheses" (Right 9) (calc "(1 + 2) * 3")
    , koan "division by zero at runtime" (Left "division by zero") (calc "8 / (3 - 3)")
    , koan "the final calculation" (Right 12) (calc "2 * (3 + 4) - 10 / 5")
    , koanWith "a dangling operator is an error" "a Left" (either (const True) (const False)) (calc "1 +")
    , koanWith "an unclosed paren is an error" "a Left" (either (const True) (const False)) (calc "(1 + 2")
    ]
