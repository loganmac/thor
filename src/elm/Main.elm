module Main exposing (..)

import Data.App as App exposing (App)
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (class)
import Http
import Page.AppAdmin as AppAdmin
import Page.AppDash as AppDash
import View.AccountMenu as AccountMenu
import View.TopNav as TopNav


---- MODEL ----


type alias Model =
    { app : App
    , topNav : TopNav.Model
    , appAdmin : AppAdmin.Model
    , appDash : AppDash.Model
    }


type alias Flags =
    { logoPath : String
    , homeLogoPath : String
    , supportLogoPath : String
    }


type TopPage appId accountId teamId
    = Dashboard
    | NewApp
    | App appId
    | AccountAdmin accountId
    | TeamAdmin teamId


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( appAdmin, appAdminCmd ) =
            AppAdmin.init

        ( appDash, appDashCmd ) =
            AppDash.init
    in
    ( { app = App.initialModel
      , topNav =
            { logoPath = flags.logoPath
            , homeLogoPath = flags.homeLogoPath
            , supportLogoPath = flags.supportLogoPath
            }
      , appAdmin = appAdmin
      , appDash = appDash
      }
    , Cmd.batch
        [ Cmd.map AppAdminMsg appAdminCmd
        , Cmd.map AppDashMsg appDashCmd
        , App.getApp "c3bff5fd-ce3e-4bfb-8ecc-f43714a3fc44" GetAppResponse
        ]
    )



---- UPDATE ----


type Msg
    = AppAdminMsg AppAdmin.Msg
    | AppDashMsg AppDash.Msg
    | GetAppResponse (Result Http.Error App)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AppAdminMsg subMsg ->
            let
                ( updated, cmd ) =
                    AppAdmin.update subMsg model.appAdmin
            in
            { model | appAdmin = updated } ! [ Cmd.map AppAdminMsg cmd ]

        AppDashMsg subMsg ->
            let
                ( updated, cmd ) =
                    AppDash.update subMsg model.appDash
            in
            { model | appDash = updated } ! [ Cmd.map AppDashMsg cmd ]

        GetAppResponse (Ok app) ->
            { model | app = app } ! []

        GetAppResponse (Err error) ->
            model ! []



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map AppDashMsg (AppDash.subscriptions model.appDash)
        ]



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "dashboard" ]
        [ TopNav.view model.topNav AccountMenu.view
        , Html.map AppAdminMsg <| AppAdmin.view model.appAdmin model.app

        -- , Html.map AppDashMsg <| AppDash.view model.appDash
        ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
