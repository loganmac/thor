module Route exposing (..)

import Data.App as App
import Data.User as User
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), Parser, map, s, string)


type Route
    = Home
    | Login SubRoute
    | Download
    | NewApp
    | AppDash App.Id
    | AppLogs App.Id
    | AppHistory App.Id SubRoute
    | AppNetwork App.Id SubRoute
    | AppConfig App.Id SubRoute
    | AppAdmin App.Id SubRoute
    | AccountAdmin User.Id SubRoute
    | TeamAdmin String SubRoute


type alias SubRoute =
    String


routes : Url.Parser (Route -> a) a
routes =
    Url.oneOf
        [ map Login (s "login" </> string)
        , map Download (s "download")
        ]


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just Home
    else
        Url.parseHash routes location
