module Set11a where

import Control.Monad
import Data.List
import System.IO

import Mooc.Todo

-- Lecture 11:
--   * The IO type
--   * do-notation
--
-- Useful functions / operations:
--   * putStrLn
--   * getLine
--   * readLn
--   * replicateM
--   * readFile
--   * lines
--
-- Do not add any new imports! E.g. Data.IORef is forbidden.

------------------------------------------------------------------------------
-- Ex 1: define an IO operation hello that prints two lines. The
-- first line should be HELLO and the second one WORLD

hello :: IO ()
hello = do
  putStrLn "HELLO"
  putStrLn "WORLD"

------------------------------------------------------------------------------
-- Ex 2: define the IO operation greet that takes a name as an
-- argument and prints a line "HELLO name".

greet :: String -> IO ()
greet name = do
  putStrLn $ "HELLO " ++ name

------------------------------------------------------------------------------
-- Ex 3: define the IO operation greet2 that reads a name from the
-- keyboard and then greets that name like the in the previous
-- exercise.
--
-- Try to use the greet operation in your solution.

greet2 :: IO ()
greet2 = do
  -- putStrLn "What is your name?"
  name <- getLine
  greet name

------------------------------------------------------------------------------
-- Ex 4: define the IO operation readWords n which reads n lines from
-- the user and produces them as a list, in alphabetical order.
--
-- Example in GHCi:
--   Set11> readWords 3
--   bob
--   alice
--   carl
--   ["alice","bob","carl"]

readWords :: Int -> IO [String]
readWords n = do
  putStrLn $ "Please enter " ++ show n ++ " words:"
  words <- replicateM n getLine
  return $ sort words

------------------------------------------------------------------------------
-- Ex 5: define the IO operation readUntil f, which reads lines from
-- the user and returns them as a list. Reading is stopped when f
-- returns True for a line. (The value for which f returns True is not
-- returned.)
--
-- Example in GHCi:
--   *Set11> readUntil (=="STOP")
--   bananas
--   garlic
--   pakchoi
--   STOP
--   ["bananas","garlic","pakchoi"]

readUntil :: (String -> Bool) -> IO [String]
readUntil f = do
  putStrLn "Please enter lines (type STOP to finish):"
  lines <- readUntil' f []
  return $ reverse lines
  where
    readUntil' f acc = do
      line <- getLine
      if f line
        then return acc
        else readUntil' f (line : acc)

------------------------------------------------------------------------------
-- Ex 6: given n, print the numbers from n to 0, one per line

countdownPrint :: Int -> IO ()
countdownPrint n = do
  -- putStrLn $ "Counting down from " ++ show n ++ ":"
  countdown n
  where
    countdown 0 = putStrLn "0"
    countdown m = do
      print m
      countdown (m - 1)

------------------------------------------------------------------------------
-- Ex 7: isums n should read n numbers from the user (one per line) and
--   1) after each number, print the running sum up to that number
--   2) finally, produce the sum of all numbers
--
-- Example:
--   1. run `isums 3`
--   2. user enters '3', should print '3'
--   3. user enters '5', should print '8' (3+5)
--   4. user enters '1', should print '9' (3+5+1)
--   5. produces 9

isums :: Int -> IO Int
isums n = do
  -- putStrLn $ "Please enter " ++ show n ++ " numbers:"
  -- sum <- isums' n 0
  -- putStrLn $ "The total sum is: " ++ show sum
  -- return sum
  isums' n 0
  where
    isums' 0 acc = return acc
    isums' m acc = do
      num <- readLn :: IO Int
      let newAcc = acc + num
      print newAcc -- putStrLn $ "Running sum: " ++ show newAcc
      isums' (m - 1) newAcc

------------------------------------------------------------------------------
-- Ex 8: when is a useful function, but its first argument has type
-- Bool. Write a function that behaves similarly but the first
-- argument has type IO Bool.

whenM :: IO Bool -> IO () -> IO ()
whenM cond op = do
  result <- cond
  when result op

------------------------------------------------------------------------------
-- Ex 9: implement the while loop. while condition operation should
-- run operation as long as condition returns True.
--
-- Examples:
--   -- prints nothing
--   while (return False) (putStrLn "IMPOSSIBLE")
--
--   -- prints YAY! as long as the user keeps answering Y
--   while ask (putStrLn "YAY!")

-- used in an example
ask :: IO Bool
ask = do putStrLn "Y/N?"
         line <- getLine
         return $ line == "Y"

while :: IO Bool -> IO () -> IO ()
while cond op = do
  whenM cond $ do
    op
    while cond op

------------------------------------------------------------------------------
-- Ex 10: given a string and an IO operation, print the string, run
-- the IO operation, print the string again, and finally return what
-- the operation returned.
--
-- Note! the operation should be run only once
--
-- Examples:
--   debug "CIAO" (return 3)
--     - prints two lines that contain CIAO
--     - returns the value 3
--   debug "BOOM" getLine
--     1. prints "BOOM"
--     2. reads a line from the user
--     3. prints "BOOM"
--     4. returns the line read from the user

debug :: String -> IO a -> IO a
debug s op = do
  putStrLn s
  result <- op
  putStrLn s
  return result
