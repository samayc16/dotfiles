-- Koan 22 checks. Read-only: edit Ciphers.hs in your workspace instead.
module Main (main) where

import KoanCheck
import Ciphers

main :: IO ()
main =
  runKoans
    "Koan 22 · Strings & ciphers"
    [ koan "caesar 3" "def abc" (caesar 3 "abc xyz")
    , koan "caesar keeps case and punctuation" "Aa!" (caesar 1 "Zz!")
    , koan "negative shift decodes" "abc" (caesar (-3) "def")
    , koan "rot13 twice is identity" "Haskell" (rot13 (rot13 "Haskell"))
    , koan "rot13" "Unfxryy" (rot13 "Haskell")
    , koan "palindrome" True (isPalindrome "A man, a plan, a canal: Panama")
    , koan "not a palindrome" False (isPalindrome "lambda")
    , koan "capitalizeWords" "The Way Of Lambda" (capitalizeWords "the way of lambda")
    ]
