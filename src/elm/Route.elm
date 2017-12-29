module Route exposing (..)

import Data.App as App
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), Parser, map, s, string)


type Route
    = Dashboard SubRoute
    | Login SubRoute
    | App App.Id SubRoute
    | NotFound


type alias SubRoute =
    String


routes : Url.Parser (Route -> a) a
routes =
    Url.oneOf
        [ map Login (s "login" </> string)
        , map App (s "app" </> App.idParser </> string)
        , map Dashboard string
        ]


fromLocation : Location -> Route
fromLocation location =
    if String.isEmpty location.hash then
        Dashboard ""
    else
        case Url.parseHash routes location of
            Just route ->
                route

            Nothing ->
                NotFound
