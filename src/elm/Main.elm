module Main exposing (..)

-- import Html.Events exposing (onClick)

import Html exposing (Html, br, div, h1, h2, header, p, text)
import Html.Attributes exposing (class, id, style)
import Page.AppAdmin as AppAdmin
import Page.AppDash as AppDash
import Page.Core.TopNav as TopNav


-- TYPES


type Page
    = Blank
    | NotFound
    | Dashboard
    | AppDash
    | AppLogs
    | AppHistory
    | AppNetwork
    | AppConfig
    | AppAdmin
    | AccountAdmin
    | TeamAdmin


type PageState
    = Loaded Page
    | TransitioningFrom Page



-- MODEL


type alias Model =
    { appAdmin : AppAdmin.Model
    , accountMenuOpen : Bool
    , appDash : AppDash.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        ( appAdminInitialModel, appAdminCmd ) =
            AppAdmin.init

        ( appDashInitialModel, appDashCmd ) =
            AppDash.init
    in
    ( { appAdmin = appAdminInitialModel
      , appDash = appDashInitialModel
      , accountMenuOpen = False
      }
    , Cmd.batch
        [ Cmd.map AppAdminMsg appAdminCmd
        , Cmd.map AppDashMsg appDashCmd
        ]
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Sub.map AppDashMsg (AppDash.subscriptions model.appDash) ]



-- UPDATE


type Msg
    = AppAdminMsg AppAdmin.Msg
    | AppDashMsg AppDash.Msg
    | ClickOutside


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AppAdminMsg subMsg ->
            let
                ( updatedAppAdmin, appAdminCmd ) =
                    AppAdmin.update subMsg model.appAdmin
            in
            ( { model | appAdmin = updatedAppAdmin }, Cmd.map AppAdminMsg appAdminCmd )

        AppDashMsg subMsg ->
            let
                ( updatedAppDash, appDashCmd ) =
                    AppDash.update subMsg model.appDash
            in
            ( { model | appDash = updatedAppDash }, Cmd.map AppDashMsg appDashCmd )

        ClickOutside ->
            ( { model | accountMenuOpen = False }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "main" ]
        [ TopNav.view
        , Html.map AppDashMsg (AppDash.view model.appDash)

        -- , Html.map AppAdminMsg (AppAdmin.view model.appAdmin)
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
