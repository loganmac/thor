module Page.App exposing (..)

import Data.App as App exposing (App)
import Html exposing (Html)
import Http
import Page.App.Admin as Admin
import Page.App.Dash as Dash


-- MODEL


type alias Model =
    { app : App, page : Page }


type Page
    = Admin Admin.Model
    | Config
    | Dash Dash.Model
    | History
    | Logs
    | Network



-- App.getApp "c3bff5fd-ce3e-4bfb-8ecc-f43714a3fc44" GetAppResponse
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



-- UPDATE


type Msg
    = AdminMsg Admin.Msg
    | DashMsg Dash.Msg
    | GetAppResponse (Result Http.Error App)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
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
