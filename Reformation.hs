{-# LANGUAGE FlexibleContexts, FlexibleInstances, MultiParamTypeClasses, ScopedTypeVariables, TypeFamilies, UndecidableInstances, ViewPatterns, QuasiQuotes, OverloadedStrings #-}

module Reformation (inputMin, inputMax) where

import HSP
import qualified Text.Reform.Generalized as G
import Text.Reform.Backend
import Text.Reform
import Data.Text.Lazy             (Text)
import Language.Haskell.HSX.QQ    (hsx)
import Data.Maybe
import Cards.Common.Hint
import Control.Applicative

-- |A highly general Reform input element that can be used for
-- templating arbitrary types of Html input fields
customInput :: ( Monad m, StringType x ~ Text
                , FormError error, FormInput input
                , XMLGenerator x, ErrorInputType error ~ input
                , EmbedAsAttr x (Attr Text FormId)
                , EmbedAsAttr x (Attr Text y))
            => (FormId -> (Maybe y) -> [XMLGenT x (XMLType x)]) -- ^ A function that, given a form id and a value of type y, produces a list of XML/HTML content
            -> (input -> Either error (Maybe y)) -- ^ A function that parses input into a Right y or a FormError
            -> (Maybe y) -- ^ A default initial value for the input field to hold
            -> Form m input error [XMLGenT x (XMLType x)] () (Maybe y) -- ^ A Formlet that is compatible with the Reform-native formlets (e.g. inputText)
customInput f getField initialValue = G.input getField f initialValue

inputNumber :: (Monad m
               , FormError error, FormInput input
               , ErrorInputType error ~ input
               , XMLGenerator x, StringType x ~ Text
               , EmbedAsAttr x (Attr Text FormId)
               , EmbedAsAttr x (Attr Text number)
               , Hint number) => (Maybe number) -- ^ A default initial numeric value that has an instance of the Hint typeclass
                              -> Form m input error [XMLGenT x (XMLType x)] () (Maybe number) -- ^ A Form returning a value of that type

-- ^A generic but concrete application of 'customInput' that permits
-- non-negative numbers as input and yields a Hint instance as output
inputNumber = customInput inputField readMaybeHintError
  where
    inputField :: (XMLGenerator x, StringType x ~ Text, EmbedAsAttr x (Attr Text FormId), EmbedAsAttr x (Attr Text number), Hint number) => (FormId -> (Maybe number) -> [XMLGenT x (XMLType x)])
    inputField i (Just a) = [ [hsx| <input type="number" min="0" step="1" id=i name=i pattern="[0-9]+" value=a /> |] ]
    inputField i Nothing = [ [hsx| <input type="number" min="0" step="1" id=i name=i pattern="[0-9]+"/> |] ]

-- | A modified special case of inputNumber that is given a placeholer
-- of 'Min'
inputMin :: (Monad m
            , FormError error, FormInput input
            , ErrorInputType error ~ input
            , XMLGenerator x, StringType x ~ Text
            , EmbedAsAttr x (Attr Text FormId)
            , EmbedAsAttr x (Attr Text number)
            , Hint number) => (Maybe number)
                           -> Form m input error [XMLGenT x (XMLType x)] () (Maybe number)

inputMin = customInput inputField readMaybeHintError
  where
    inputField :: (XMLGenerator x, StringType x ~ Text, EmbedAsAttr x (Attr Text FormId), EmbedAsAttr x (Attr Text number), Hint number) => (FormId -> (Maybe number) -> [XMLGenT x (XMLType x)])
    inputField i (Just a) = [ [hsx| <input type="number" placeholder="Min" min="0" step="1" id=i name=i pattern="[0-9]+" value=a />|] ]
    inputField i Nothing = [ [hsx| <input type="number" placeholder="Min" min="0" step="1" id=i name=i pattern="[0-9]+"/>|] ]

-- | A modified special case of inputNumber that is given a placeholder
-- of 'Max'
inputMax :: (Monad m
            , FormError error, FormInput input
            , ErrorInputType error ~ input
            , XMLGenerator x, StringType x ~ Text
            , EmbedAsAttr x (Attr Text FormId)
            , EmbedAsAttr x (Attr Text number)
            , Hint number) => (Maybe number)
                           -> Form m input error [XMLGenT x (XMLType x)] () (Maybe number)

inputMax = customInput inputField readMaybeHintError
  where
    inputField :: (XMLGenerator x, StringType x ~ Text, EmbedAsAttr x (Attr Text FormId), EmbedAsAttr x (Attr Text number), Hint number) => (FormId -> (Maybe number) -> [XMLGenT x (XMLType x)])
    inputField i (Just a) = [ [hsx|<input type="number" placeholder="Max" min="0" step="1" id=i name=i pattern="[0-9]+" value=a />|] ]
    inputField i Nothing = [ [hsx|<input type="number" placeholder="Max" min="0" step="1" id=i name=i pattern="[0-9]+"/>|] ]

-- | 'readMaybeHintError' takes FormInput that is supposed to be converted into
-- a Hint instance, returning a Left error if no conversion is possible,
-- and a Right Maybe-Hint-value if successful
readMaybeHintError :: (FormError error, FormInput input, ErrorInputType error ~ input, Hint number) => input -> Either error (Maybe number)
readMaybeHintError i = readMaybeH <$> (getInputString i)
  where
    readMaybeH "" = Nothing
    readMaybeH x = Just (readH x)
