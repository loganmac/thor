module Page.App exposing (..)

-- TODO: remove/refactor into subpages

import Data.App as App exposing (App)
import Html exposing (Html)
import Http
import Navigation
import Page.App.Admin as Admin
import Page.App.Dash as Dash
import UrlParser as Url exposing ((</>))


-- MODEL


type alias Model =
    { page : Page
    , app : Maybe App
    }


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
    , app = Nothing
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
            { model | app = Just app } ! []

        ( GetAppResponse (Err error), _ ) ->
            -- TODO: Don't swallow error, show error or go
            -- to not found on an invalid url
            model ! [ Navigation.newUrl "#not-found" ]

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            model ! []



-- VIEW


view : Model -> Html Msg
view model =
    case model.app of
        Just app ->
            case model.page of
                Admin subModel ->
                    Html.map AdminMsg <| Admin.view subModel app

                Dash subModel ->
                    Html.map DashMsg <| Dash.view subModel

                Logs ->
                    Html.div [] [ Html.text "Logs not implemented." ]

                History ->
                    Html.div [] [ Html.text "History not implemented." ]

                Network ->
                    Html.div [] [ Html.text "Network not implemented." ]

                Config ->
                    Html.div [] [ Html.text "Config not implemented." ]

        Nothing ->
            Html.div [] [ Html.text "Loading..." ]
