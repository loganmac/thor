module Main exposing (..)

import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (class)
import Navigation exposing (Location)
import Page.App as App
import Page.Dashboard as Dashboard
import Page.Login as Login
import Route
import View.AccountMenu as AccountMenu
import View.TopNav as TopNav


---- MODEL ----


type alias Model =
    { page : Page
    , topNav : TopNav.Model
    }


type alias Flags =
    { logoPath : String
    , homeLogoPath : String
    , supportLogoPath : String
    }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        ( page, cmd ) =
            navigateTo (Route.fromLocation location)
    in
    { page = page
    , topNav =
        { logoPath = flags.logoPath
        , homeLogoPath = flags.homeLogoPath
        , supportLogoPath = flags.supportLogoPath
        }
    }
        ! [ cmd ]


type Page
    = NotFound
    | Login Login.Model
    | Dashboard Dashboard.Model
    | App App.Model



---- UPDATE ----


type Msg
    = SetRoute Route.Route
    | LoginMsg String
    | DashboardMsg Dashboard.Msg
    | AppMsg App.Msg


navigateTo : Route.Route -> ( Page, Cmd Msg )
navigateTo route =
    ( NotFound, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( SetRoute route, _ ) ->
            let
                ( page, cmd ) =
                    navigateTo route
            in
            { model | page = page } ! [ cmd ]

        ( LoginMsg subMsg, Login subModel ) ->
            model ! []

        ( DashboardMsg subMsg, Dashboard submodel ) ->
            model ! []

        ( AppMsg subMsg, App subModel ) ->
            model ! []

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            model ! []



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        NotFound ->
            Sub.none

        Login subModel ->
            Sub.none

        Dashboard subModel ->
            Sub.map DashboardMsg <| Dashboard.subscriptions subModel

        App subModel ->
            Sub.map AppMsg <| App.subscriptions subModel



---- VIEW ----


view : Model -> Html Msg
view model =
    case model.page of
        NotFound ->
            div [] [ text "Not found." ]

        Login subModel ->
            div [] [ text "Login page: not implemented" ]

        Dashboard subModel ->
            viewAuthedWrapper model <|
                Html.map DashboardMsg <|
                    Dashboard.view subModel

        App subModel ->
            viewAuthedWrapper model <|
                Html.map AppMsg <|
                    App.view subModel


viewAuthedWrapper : Model -> Html Msg -> Html Msg
viewAuthedWrapper model inner =
    div [ class "dashboard" ]
        [ TopNav.view model.topNav AccountMenu.view
        , inner
        ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
