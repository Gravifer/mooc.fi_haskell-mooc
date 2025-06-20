-- Exercise set 3b
--
-- This is a special exercise set. The exercises are about
-- implementing list functions using recursion and pattern matching,
-- without using any standard library functions. For this reason,
-- you'll be working in a limited environment where almost none of the
-- standard library is available.
--
-- At least the following standard library functions are missing:
--  * (++)
--  * head
--  * tail
--  * map
--  * filter
--  * concat
--  * (!!)
--
-- The (:) operator is available, as is list literal syntax [a,b,c].
--
-- Feel free to use if-then-else, guards, and ordering functions (< and > etc.).
--
-- The tests will check that you haven't added imports :)

{-# LANGUAGE NoImplicitPrelude #-}

module Set3b where

import Mooc.LimitedPrelude
import Mooc.Todo

------------------------------------------------------------------------------
-- Ex 1: given numbers start, count and end, build a list that starts
-- with count copies of start and ends with end.
--
-- Use recursion and the : operator to build the list.
--
-- Examples:
--   buildList 1 5 2 ==> [1,1,1,1,1,2]
--   buildList 7 0 3 ==> [3]

buildList :: Int -> Int -> Int -> [Int]
-- buildList start 0 end = [end]
-- buildList start count end = start : buildList start (count-1) end
buildList start count end = case count of
  0 -> [end]
  _ -> start : buildList start (count - 1) end
-- buildList start count end = go start count [end]
--   where go :: Int -> Int -> [Int] -> [Int]
--         go _ 0 acc = acc
--         go s n acc = go s (n-1) (s:acc)

------------------------------------------------------------------------------
-- Ex 2: given i, build the list of sums [1, 1+2, 1+2+3, .., 1+2+..+i]
--
-- Use recursion and the : operator to build the list.
--
-- Ps. you'll probably need a recursive helper function

myreverse :: [a] -> [a]
myreverse xs = go xs []
  where go [] acc = acc
        go (x:xs) acc = go xs (x:acc)

sums :: Int -> [Int]
sums i = sumsOf [1..i] -- * from Ex 6 in this file; using `..` doesn't feel like cheating
-- sums i = go 0 1 -- * model solution
--   where go sum j
--           | j>i = []
--           | otherwise = (sum+j) : go (sum+j) (j+1)
-- sums i = myreverse (go 1 []) -- this is a more direct implementation, but it is not tail recursive
--   where go :: Int -> [Int] -> [Int]
--         go k acc
--           | k > i = acc
--           | otherwise = case acc of
--               [] -> go (k + 1) [k]
--               (x:_) -> go (k + 1) ((x + k) : acc)
-- sums i -- * using the sum formula feels like cheating in this exercise
--   | i <= 0     = []
--   | otherwise = go 1 i []
--   where go :: Int -> Int -> [Int] -> [Int]
--         go k i _ | k > i = []
--         go k i acc = k*(k+1) `div` 2 : go (k + 1) i acc
-- sums i = [ m * (m + 1) `div` 2 | m <- [1..i] ] -- * comprehensions shouldn't be allowed in this exercise

------------------------------------------------------------------------------
-- Ex 3: define a function mylast that returns the last value of the
-- given list. For an empty list, a provided default value is
-- returned.
--
-- Use only pattern matching and recursion (and the list constructors : and [])
--
-- Examples:
--   mylast 0 [] ==> 0
--   mylast 0 [1,2,3] ==> 3

mylast :: a -> [a] -> a
mylast def xs = case xs of
  []     -> def
  [x]    -> x -- * not actually needed
  (x:xs) -> mylast def xs

------------------------------------------------------------------------------
-- Ex 4: safe list indexing. Define a function indexDefault so that
--   indexDefault xs i def
-- gets the element at index i in the list xs. If i is not a valid
-- index, def is returned.
--
-- Use only pattern matching and recursion (and the list constructors : and [])
--
-- Examples:
--   indexDefault [True] 1 False         ==>  False
--   indexDefault [10,20,30] 0 7         ==>  10
--   indexDefault [10,20,30] 2 7         ==>  30
--   indexDefault [10,20,30] 3 7         ==>  7
--   indexDefault ["a","b","c"] (-1) "d" ==> "d"

indexDefault :: [a] -> Int -> a -> a
indexDefault xs i def = case (xs, i) of
  ([], _) -> def
  (x:_, 0) -> x
  (x:xs, n) | n < 0     -> def
            | otherwise -> indexDefault xs (n - 1) def
-- indexDefault xs i def = go xs i
--   where -- go :: [a] -> Int -> a -- ! adding a type notation would cause incorrect wider interpretion; see ScopedTypeVariables
--         go [] _ = def
--         go (x:xs) 0 = x
--         go (x:xs) n
--           | n < 0     = def
--           | otherwise = go xs (n - 1)

------------------------------------------------------------------------------
-- Ex 5: define a function that checks if the given list is in
-- increasing order.
--
-- Use pattern matching and recursion to iterate through the list.
--
-- Examples:
--   sorted [1,2,3] ==> True
--   sorted []      ==> True
--   sorted [2,7,7] ==> True
--   sorted [1,3,2] ==> False
--   sorted [7,2,7] ==> False

sorted :: [Int] -> Bool
sorted xs = case xs of
  []       -> True
  [x]      -> True
  (x:y:xs) -> (x <= y) && sorted (y:xs)

------------------------------------------------------------------------------
-- Ex 6: compute the partial sums of the given list like this:
--
--   sumsOf [a,b,c]  ==>  [a,a+b,a+b+c]
--   sumsOf [a,b]    ==>  [a,a+b]
--   sumsOf []       ==>  []
--
-- Use pattern matching and recursion (and the list constructors : and [])

sumsOf :: [Int] -> [Int]
sumsOf xs = go xs 0
  where go :: [Int] -> Int -> [Int]
        go [] _ = []
        go (x:xs) acc = (acc + x) : go xs (acc + x)

------------------------------------------------------------------------------
-- Ex 7: implement the function merge that merges two sorted lists of
-- Ints into a sorted list
--
-- Use only pattern matching and recursion (and the list constructors : and [])
--
-- Examples:
--   merge [1,3,5] [2,4,6] ==> [1,2,3,4,5,6]
--   merge [1,1,6] [1,2]   ==> [1,1,1,2,6]

merge :: [Int] -> [Int] -> [Int] -- a piece from a DnC merge-sort; note that each argument is sorted
merge xs ys = case (xs, ys) of
  ([], _) -> ys
  (_, []) -> xs
  (x:xs', y:ys')
    | x <= y    -> x : merge xs' ys
    | otherwise -> y : merge xs ys'

------------------------------------------------------------------------------
-- Ex 8: compute the biggest element, using a comparison function
-- passed as an argument.
--
-- That is, implement the function mymaximum that takes
--
-- * a function `bigger` :: a -> a -> Bool
-- * a value `initial` of type a
-- * a list `xs` of values of type a
--
-- and returns the biggest value it sees, considering both `initial`
-- and all element in `xs`.
--
-- Examples:
--   mymaximum (>) 3 [] ==> 3
--   mymaximum (>) 0 [1,3,2] ==> 3
--   mymaximum (>) 4 [1,3,2] ==> 4    -- initial value was biggest
--   mymaximum (<) 4 [1,3,2] ==> 1    -- note changed biggerThan
--   mymaximum (\(a,b) (c,d) -> b > d) ("",0) [("Banana",7),("Mouse",8)]
--     ==> ("Mouse",8)

mymaximum :: (a -> a -> Bool) -> a -> [a] -> a
mymaximum bigger initial xs = case xs of
  []     -> initial
  (x:xs) -> mymaximum bigger (if bigger x initial then x else initial) xs

------------------------------------------------------------------------------
-- Ex 9: define a version of map that takes a two-argument function
-- and two lists. Example:
--
--   map2 f [x,y,z,w] [a,b,c]  ==> [f x a, f y b, f z c]
--
-- If the lists have differing lengths, ignore the trailing elements
-- of the longer list.
--
-- Use recursion and pattern matching. Do not use any library functions.

map2 :: (a -> b -> c) -> [a] -> [b] -> [c]
map2 f xs ys = case (xs, ys) of -- * I avoid using a, b, c for terms
  ([], _) -> []
  (_, []) -> []
  (x1:xs', y1:ys') -> f x1 y1 : map2 f xs' ys'

------------------------------------------------------------------------------
-- Ex 10: implement the function maybeMap, which works a bit like a
-- combined map & filter.
---
-- maybeMap is given a list ([a]) and a function of type a -> Maybe b.
-- This function is called for all values in the list. If the function
-- returns Just x, x will be in the result list. If the function
-- returns Nothing, no value gets added to the result list.
--
-- Examples:
--
-- let f x = if x>0 then Just (2*x) else Nothing
-- in maybeMap f [0,1,-1,4,-2,2]
--   ==> [2,8,4]
--
-- maybeMap Just [1,2,3]
--   ==> [1,2,3]
--
-- maybeMap (\x -> Nothing) [1,2,3]
--   ==> []

maybeMap :: (a -> Maybe b) -> [a] -> [b]
maybeMap f xs = case xs of
  []     -> []
  (x:xs) -> case f x of
    Just y  -> y : maybeMap f xs
    Nothing -> maybeMap f xs
