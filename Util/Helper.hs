module Util.Helper where

import Control.Monad
import Control.Applicative
import Util.List (for, one)
import Data.Char
import Util.Generic

-- |The @||@ operator lifted to applicative functors
afor :: (Applicative f) => f Bool -> f Bool -> f Bool
afor = liftA2 (||)

-- |Ceiling-division for calculating how many bins to use
cdiv :: Int -> Int -> Int
x`cdiv`y | x`mod`y == 0 = x`div`y
         | otherwise = x`div`y + 1

-- |A function that converts paired monads to monadic pairs
mpair :: Monad m => (m a, m b) -> m (a,b)
mpair (mx, my) = do { x <- mx; y <- my; return (x, y) }

-- |A function that converts functors to functor pairs
fpair :: Applicative f => (f a, f b) -> f (a,b)
fpair (fx, fy) = (,) <$> fx <*> fy

-- |A 'wrapped' function treats values as singleton lists
-- > wrapped f $ x = f [x]
wrapped :: ([a] -> b) -> (a -> b)
wrapped = (.one)

-- |Converts a normal string-parser into a basic Read(er)
rdr :: (String -> a) -> (ReadS a)
rdr = (wrapped (`zip`[""]) .)

-- |Composes a list of same-type transformations
proc :: [a -> a] -> a -> a
proc = foldl1 (.)

-- |Composes transformation generators over the same seed
procmap :: [a -> b -> b] -> a -> b -> b
procmap = (proc.).(.flip ($)).for

-- |Constant on unit
unity :: a -> (() -> a)
unity x = (\() -> x)


-- |Converts a string to titlecase (first character uppercase, all others
-- lowercase)
titleCase :: String -> String
titleCase xs = case xs of
                 [] -> []
                 y:ys -> toUpper y : map toLower ys


fromLeft :: Either a b -> a
fromLeft x = case x of
               (Left x) -> x
               (Right y) -> error $ "fromLeft: (Right "++(reveal y)++")"


fromRight :: Either a b -> b
fromRight x = case x of
                (Left y) -> error $ "fromRight: (Left "++(reveal y)++")"
                (Right x) -> x

fromRight' :: Show a => Either a b -> b
fromRight' x = case x of
                 (Left y) -> error $ "fromRight: (Left "++(show y)++")"
                 (Right x) -> x

fromEither :: Either a a -> a
fromEither x = case x of
                 (Left y) -> y
                 (Right y) -> y
