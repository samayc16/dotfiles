-- | Tiny assertion harness for the Haskell koans. Uses only `base` + `directory`,
-- both bundled with GHC, so koans run fully offline with `runghc`.
module KoanCheck
  ( Koan
  , koan
  , koanWith
  , koanIO
  , koanOutput
  , captureOutput
  , runKoans
  ) where

import Control.Exception (SomeException, displayException, evaluate, finally, try)
import Control.Monad (forM)
import Data.List (intercalate, isInfixOf)
import GHC.IO.Handle (hDuplicate, hDuplicateTo)
import System.Directory (getTemporaryDirectory, removeFile)
import System.Exit (exitFailure)
import System.IO
import System.Timeout (timeout)

data Result = Pass | Fail String

-- | A named check. Build them with 'koan', 'koanWith', 'koanIO' or 'koanOutput'.
data Koan = Koan String (IO Result)

-- | @koan name expected actual@ passes when @actual == expected@.
koan :: (Eq a, Show a) => String -> a -> a -> Koan
koan name expected actual = Koan name (compareValues expected actual)

-- | Passes when the predicate holds; @want@ describes the expectation for the failure message.
koanWith :: Show a => String -> String -> (a -> Bool) -> a -> Koan
koanWith name want ok actual = Koan name $ do
  r <- guarded (evaluate (ok actual))
  case r of
    Left why -> pure (Fail why)
    Right True -> pure Pass
    Right False -> do
      got <- render actual
      pure (Fail ("expected " ++ want ++ "\n      got      " ++ got))

-- | Runs an IO action and compares its result.
koanIO :: (Eq a, Show a) => String -> a -> IO a -> Koan
koanIO name expected act = Koan name $ do
  r <- guarded act
  either (pure . Fail) (compareValues expected) r

-- | Runs an IO action and compares everything it printed to stdout.
koanOutput :: String -> String -> IO () -> Koan
koanOutput name expected act = Koan name $ do
  r <- guarded (fst <$> captureOutput act)
  either (pure . Fail) (compareValues expected) r

-- | Runs an action with stdout redirected; returns (what it printed, its result).
captureOutput :: IO a -> IO (String, a)
captureOutput act = do
  tmp <- getTemporaryDirectory
  (path, h) <- openTempFile tmp "koan-stdout.txt"
  hSetEncoding h utf8
  hFlush stdout
  saved <- hDuplicate stdout
  value <- (hDuplicateTo h stdout >> act) `finally` (hFlush stdout >> hDuplicateTo saved stdout >> hClose h)
  printed <- readFile' path
  removeFile path
  pure (printed, value)

compareValues :: (Eq a, Show a) => a -> a -> IO Result
compareValues expected actual = do
  r <- guarded (evaluate (actual == expected))
  case r of
    Left why -> pure (Fail why)
    Right True -> pure Pass
    Right False -> do
      got <- render actual
      pure (Fail ("expected " ++ show expected ++ "\n      got      " ++ got))

-- | Show a value, even if forcing it blows up.
render :: Show a => a -> IO String
render x = either ("<" ++) id <$> guarded (evaluate (forceString (show x)))
  where
    forceString s = length s `seq` s

tryAny :: IO a -> IO (Either SomeException a)
tryAny = try

-- | Catch exceptions and runaway loops, turning them into friendly messages.
guarded :: IO a -> IO (Either String a)
guarded act = do
  r <- timeout 3000000 (tryAny act)
  pure $ case r of
    Nothing -> Left "took longer than 3s: an infinite loop, or forcing an infinite list?"
    Just (Left e) -> Left (explain e)
    Just (Right v) -> Right v

explain :: SomeException -> String
explain e
  | "undefined" `isInfixOf` msg = "not implemented yet: replace the `undefined`"
  | otherwise = "crashed: " ++ takeWhile (/= '\n') msg
  where
    msg = displayException e

-- | Run every koan, print a report and exit non-zero unless all pass.
runKoans :: String -> [Koan] -> IO ()
runKoans title koans = do
  hSetEncoding stdout utf8
  putStrLn ("☯ " ++ title)
  results <- forM koans $ \(Koan name run) -> do
    r <- run
    case r of
      Pass -> putStrLn ("  ✔ " ++ name)
      Fail why -> putStrLn ("  ✘ " ++ name ++ "\n      " ++ indent why)
    hFlush stdout
    pure r
  let passed = length [() | Pass <- results]
      total = length results
  putStrLn ""
  putStrLn ("  " ++ bar passed total ++ "  " ++ show passed ++ "/" ++ show total ++ " koans")
  if passed == total
    then putStrLn "  ✨ Enlightenment. Every koan passes."
    else do
      putStrLn "  Meditate on the first ✘ above, edit your file, and check again."
      exitFailure
  where
    indent = intercalate "\n      " . lines
    bar n t = replicate n '█' ++ replicate (t - n) '░'
