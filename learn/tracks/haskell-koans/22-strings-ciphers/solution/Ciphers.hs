-- | Koan 22 · Strings & ciphers
module Ciphers where

import Data.Char (chr, isAlpha, isLower, isUpper, ord, toLower, toUpper)

caesar :: Int -> String -> String
caesar n = map shift
  where
    shift c
      | isLower c = rotate 'a' c
      | isUpper c = rotate 'A' c
      | otherwise = c
    rotate base c = chr (ord base + (ord c - ord base + n) `mod` 26)

rot13 :: String -> String
rot13 = caesar 13

isPalindrome :: String -> Bool
isPalindrome s = cleaned == reverse cleaned
  where
    cleaned = [toLower c | c <- s, isAlpha c]

capitalizeWords :: String -> String
capitalizeWords = unwords . map capitalize . words
  where
    capitalize [] = []
    capitalize (c : cs) = toUpper c : cs
