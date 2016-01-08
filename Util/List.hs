module Util.List where

import Util.Conditional
import Data.Functor

infix 9 !?
infix 9 ??
infixr 8 ??.
infixl 9 !@

-- |Convenience function to test for non-emptiness
full = not . null

-- |Filters list with simultaneously traversed boolean mask
-- prop> filtrate (map f xs) xs = filter f xs
filtrate :: [Bool] -> [a] -> [a]
filtrate [] _ = []
filtrate _ [] = []
filtrate (p:ps) (x:xs) = (p?:(x:)) $ filtrate ps xs

-- |Safe fetcher-applicator that returns default value for out-of-range indices
(!?) :: (a -> b) -> b -> Int -> ([a] -> b)
(f!?y) n xs
  | n < 0
  || n >= length xs
  = y
  | otherwise
  = f (xs!!n)

-- |Identity transformation for empty list, generated transformation
-- otherwise (compare with '?')
(??) :: ([a] -> (b -> b)) -> [a] -> (b -> b)
f??[]=id
f??x =f x

-- |Generator for '??'
(??.) :: ([a] -> (b -> b)) -> (c -> [a]) -> c -> (b -> b)
f??.g = (f??).g

-- |'for' is syntactic convenience for 'map' where the function is more
-- complicated than the list; it is purely an argument-flipped 'map'.
for :: [a] -> (a -> b) -> [b]
for = flip map

-- |'one' converts a value to a singleton list
one :: a -> [a]
one = (:[])

-- |'once' wraps a function result in a singleton list
once :: (a -> b) -> (a -> [b])
once = (one.)

-- |'mono' wraps values inside functors, converting @f a@ to a @f [a]@ by lifted wrapping
mono :: Functor f => f a -> f [a]
mono = fmap one

-- |The 'headDef' function returns a default value for an empty list, or
-- the head of a non-empty list
headDef :: a -> [a] -> a
headDef x [] = x
headDef _ (x:_) = x


-- |Syntactic convenience for second element of a list
neck :: [a] -> a
neck = (!!1)

-- |Syntactic convenience for third element of a list
body :: [a] -> a
body = (!!2)

-- |The 'mmap' function maps over maybe-lists, returning empty for
-- Nothing or the mapped list for Just a list
--
-- prop> mmap f (Just xs) = map f xs
mmap :: (a -> b) -> Maybe [a] -> [b]
mmap = (?/).map

-- | Retrieves multiple indices of a list in one pass.
-- This works as long as the index list is sorted and contains no
-- duplicates: the last element in the resulting list is the last
-- element of the longest sorted, unduplicated, in-range prefix of the
-- index list.
--
-- prop> _!\@[] = []
-- prop> []!\@_ = []
-- prop> xs!\@(one i) = (one!?[]) i xs
-- prop> xs!\@is = xs!\@(tail.filter((==)<$>nub<*>sort).heads$is)
(!@) :: [a] -> [Int] -> [a]
[]!@i = []
x!@[] = []
(x:xs)!@(i:is)
  | i == 0 = x:xs!@map pred is
  | i <  0 = []
  | otherwise = xs!@map pred (i:is)
