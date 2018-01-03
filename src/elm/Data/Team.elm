module Data.Team exposing (..)

import UrlParser


type Id
    = Id String


idParser : UrlParser.Parser (Id -> a) a
idParser =
    UrlParser.custom "ID" <| Ok << Id
