module Main exposing (..)

import Html exposing (Html, div, h1, img, text)
import Page.AppAdmin as AppAdmin
import Page.AppDash as AppDash
import View.AccountMenu as AccountMenu
import View.TopNav as TopNav


---- MODEL ----


type alias Model =
    { logoPath : String
    , appAdmin : AppAdmin.Model
    , appDash : AppDash.Model
    }


type alias Flags =
    { logoPath : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( appAdmin, appAdminCmd ) =
            AppAdmin.init

        ( appDash, appDashCmd ) =
            AppDash.init
    in
    ( { logoPath = flags.logoPath
      , appAdmin = appAdmin
      , appDash = appDash
      }
    , Cmd.batch
        [ Cmd.map AppAdminMsg appAdminCmd
        , Cmd.map AppDashMsg appDashCmd
        ]
    )



---- UPDATE ----


type Msg
    = AppAdminMsg AppAdmin.Msg
    | AppDashMsg AppDash.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AppAdminMsg subMsg ->
            let
                ( updated, cmd ) =
                    AppAdmin.update subMsg model.appAdmin
            in
            ( { model | appAdmin = updated }, Cmd.map AppAdminMsg cmd )

        AppDashMsg subMsg ->
            let
                ( updated, cmd ) =
                    AppDash.update subMsg model.appDash
            in
            ( { model | appDash = updated }, Cmd.map AppDashMsg cmd )



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map AppDashMsg (AppDash.subscriptions model.appDash)
        ]



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ TopNav.view AccountMenu.view
        , Html.map AppAdminMsg <| AppAdmin.view model.appAdmin

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
