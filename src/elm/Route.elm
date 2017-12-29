module Route exposing (..)

import Data.App as App
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>))


type Route
    = NotFoundRoute
    | LoginRoute String
    | RegisterRoute
    | ForgotPasswordRoute
    | DashboardRoute
    | NewAppRoute
    | AccountAdminRoute
    | TeamAdminRoute String
    | DownloadRoute
    | AppAdminRoute
    | AppConfigRoute
    | AppDashRoute App.Id
    | AppHistoryRoute
    | AppLogsRoute
    | AppNetworkRoute


routes : Url.Parser (Route -> a) a
routes =
    Url.oneOf
        [ Url.map DashboardRoute Url.top
        , Url.map DashboardRoute (Url.s "apps")
        , Url.map LoginRoute (Url.s "login" </> Url.string)
        , Url.map NotFoundRoute (Url.s "not-found")
        , Url.map NewAppRoute (Url.s "apps" </> Url.s "new")
        , Url.map AccountAdminRoute (Url.s "account-admin")
        , Url.map TeamAdminRoute (Url.s "teams" </> Url.string </> Url.s "admin")
        , Url.map DownloadRoute (Url.s "download")
        , Url.map AppDashRoute (Url.s "apps" </> App.idParser)
        , Url.map AppAdminRoute (Url.s "admin")
        , Url.map AppConfigRoute (Url.s "config")
        , Url.map AppHistoryRoute (Url.s "history")
        , Url.map AppLogsRoute (Url.s "logs")
        , Url.map AppNetworkRoute (Url.s "network")
        ]


parseRoute : Location -> Route
parseRoute location =
    if String.isEmpty location.hash then
        DashboardRoute
    else
        case Url.parseHash routes location of
            Just route ->
                route

            Nothing ->
                NotFoundRoute
