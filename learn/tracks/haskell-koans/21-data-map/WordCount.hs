-- | Koan 21 · Data.Map
module WordCount where

import Data.Char (isAlpha, toLower)
import Data.List (sortBy)
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Data.Ord (Down (..), comparing)

wordFreq :: String -> Map String Int
wordFreq text = undefined

topN :: Int -> Map String Int -> [(String, Int)]
topN n freq = undefined

inventory :: [(String, Int)] -> Map String Int
inventory items = undefined

restock :: String -> Int -> Map String Int -> Map String Int
restock item n stock = undefined

countOf :: String -> Map String Int -> Int
countOf item stock = undefined
