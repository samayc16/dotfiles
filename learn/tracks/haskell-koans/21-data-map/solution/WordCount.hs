-- | Koan 21 · Data.Map
module WordCount where

import Data.Char (isAlpha, toLower)
import Data.List (sortBy)
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Data.Ord (Down (..), comparing)

wordFreq :: String -> Map String Int
wordFreq text = Map.fromListWith (+) [(w, 1) | w <- words cleaned]
  where
    cleaned = [if isAlpha c then toLower c else ' ' | c <- text]

topN :: Int -> Map String Int -> [(String, Int)]
topN n freq = take n (sortBy (comparing (\(w, c) -> (Down c, w))) (Map.toList freq))

inventory :: [(String, Int)] -> Map String Int
inventory items = Map.fromListWith (+) items

restock :: String -> Int -> Map String Int -> Map String Int
restock item n stock = Map.insertWith (+) item n stock

countOf :: String -> Map String Int -> Int
countOf item stock = Map.findWithDefault 0 item stock
