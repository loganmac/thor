module Page.Dashboard.App exposing (..)

import Data.App as App exposing (App)
import Html exposing (Html)
import Http
import Page.Dashboard.App.Admin as Admin
import Page.Dashboard.App.Dash as Dash
import UrlParser as Url exposing ((</>))


-- MODEL


type alias Model =
    { page : Page, app : App }


type Page
    = Admin Admin.Model
    | Config
    | Dash Dash.Model
    | History
    | Logs
    | Network


init : App.Id -> ( Model, Cmd Msg )
init (App.Id id) =
    let
        ( initDash, dashCmd ) =
            Dash.init
    in
    { page = Dash initDash
    , app = App.initialModel
    }
        ! [ dashCmd, App.getApp id GetAppResponse ]



--
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ appSubscriptions model
        , pageSubscriptions model.page
        ]


appSubscriptions : Model -> Sub Msg
appSubscriptions model =
    Sub.none


pageSubscriptions : Page -> Sub Msg
pageSubscriptions page =
    case page of
        Dash subModel ->
            Sub.map DashMsg <| Dash.subscriptions subModel

        _ ->
            Sub.none



-- ROUTING


type Route
    = AdminRoute
    | ConfigRoute
    | DashRoute
    | HistoryRoute
    | LogsRoute
    | NetworkRoute


routeParser : Url.Parser (App.Id -> Route -> a) a
routeParser =
    Url.s "app"
        </> App.idParser
        </> Url.oneOf
                [ Url.map DashRoute Url.top
                , Url.map AdminRoute (Url.s "admin")
                , Url.map ConfigRoute (Url.s "config")
                , Url.map HistoryRoute (Url.s "history")
                , Url.map LogsRoute (Url.s "logs")
                , Url.map NetworkRoute (Url.s "network")
                ]


navigateTo : Route -> Model -> ( Model, Cmd Msg )
navigateTo route model =
    case route of
        AdminRoute ->
            let
                ( admin, cmd ) =
                    Admin.init
            in
            { model | page = Admin admin } ! [ Cmd.map AdminMsg cmd ]

        ConfigRoute ->
            { model | page = Config } ! []

        DashRoute ->
            let
                ( dash, cmd ) =
                    Dash.init
            in
            { model | page = Dash dash } ! [ Cmd.map DashMsg cmd ]

        HistoryRoute ->
            { model | page = History } ! []

        LogsRoute ->
            { model | page = Logs } ! []

        NetworkRoute ->
            { model | page = Network } ! []



-- UPDATE


type Msg
    = RouteChange Route
    | AdminMsg Admin.Msg
    | DashMsg Dash.Msg
    | GetAppResponse (Result Http.Error App)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( RouteChange route, _ ) ->
            navigateTo route model

        ( AdminMsg subMsg, Admin subModel ) ->
            let
                ( updated, cmd ) =
                    Admin.update subMsg subModel
            in
            { model | page = Admin updated } ! [ Cmd.map AdminMsg cmd ]

        ( DashMsg subMsg, Dash subModel ) ->
            let
                ( updated, cmd ) =
                    Dash.update subMsg subModel
            in
            { model | page = Dash updated } ! [ Cmd.map DashMsg cmd ]

        ( GetAppResponse (Ok app), _ ) ->
            { model | app = app } ! []

        ( GetAppResponse (Err error), _ ) ->
            -- TODO: Don't swallow error
            model ! []

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            model ! []



-- VIEW


view : Model -> Html Msg
view model =
    case model.page of
        Admin subModel ->
            Html.map AdminMsg <| Admin.view subModel model.app

        Dash subModel ->
            Html.map DashMsg <| Dash.view subModel

        Logs ->
            Html.div [] []

        History ->
            Html.div [] []

        Network ->
            Html.div [] []

        Config ->
            Html.div [] []