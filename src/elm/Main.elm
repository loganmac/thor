module Main exposing (..)

import Data.App as App exposing (App)
import Data.User as User exposing (User)
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (class)
import Http
import Navigation exposing (Location)
import Page.AccountAdmin as AccountAdmin
import Page.AppAdmin as AppAdmin
import Page.AppDash as AppDash
import Route
import View.AccountMenu as AccountMenu
import View.TopNav as TopNav


---- MODEL ----


type alias Model =
    { app : Maybe App
    , user : Maybe User
    , page : Page
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
    ( { app = Nothing
      , user = Nothing
      , page = page
      , topNav =
            { logoPath = flags.logoPath
            , homeLogoPath = flags.homeLogoPath
            , supportLogoPath = flags.supportLogoPath
            }
      }
    , Cmd.batch
        [ -- TODO: Don't hardcode these
          -- App.getApp "c3bff5fd-ce3e-4bfb-8ecc-f43714a3fc44" GetAppResponse
          User.getUser "190e0469-08a5-47b5-a78b-c88221df3067" GetUserResponse
        ]
    )



-- PAGE MODELING
{--| Pages are organized heirarchically.

There are two top level groupings,
`Anonymous` and `Authenticated`, differing by whether you are logged in or
need user data, or not.

AuthenticatedPages are also grouped by whether they are specific to an app,
or top level (for the whole account).
-}


type Page
    = Anonymous AnonymousPage
    | Authenticated AuthenticatedPage


type AnonymousPage
    = Login
    | NotFound


type AuthenticatedPage
    = AppSpecific AppSpecificPage
    | TopLevel TopLevelPage


type TopLevelPage
    = Home
    | Download
    | NewApp
    | AccountAdmin AccountAdmin.Model
    | TeamAdmin


type AppSpecificPage
    = AppDash AppDash.Model
    | AppLogs
    | AppHistory
    | AppNetwork
    | AppConfig
    | AppAdmin AppAdmin.Model



---- UPDATE ----


type Msg
    = SetRoute (Maybe Route.Route)
    | AccountAdminMsg AccountAdmin.Msg
    | AppAdminMsg AppAdmin.Msg
    | AppDashMsg AppDash.Msg
    | GetAppResponse (Result Http.Error App)
    | GetUserResponse (Result Http.Error User)


navigateTo : Maybe Route.Route -> ( Page, Cmd Msg )
navigateTo route =
    ( Authenticated <| TopLevel <| Home, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.page of
        Anonymous page ->
            updateAnonymous msg model page

        Authenticated page ->
            updateAuthenticated msg model page


updateAnonymous : Msg -> Model -> AnonymousPage -> ( Model, Cmd Msg )
updateAnonymous msg model page =
    case page of
        Login ->
            model ! []

        NotFound ->
            model ! []

        _ ->
            -- ignore message for old page
            model ! []


updateAuthenticated : Msg -> Model -> AuthenticatedPage -> ( Model, Cmd Msg )
updateAuthenticated msg model page =
    case page of
        TopLevel topLevelPage ->
            model ! []

        AppSpecific appSpecificPage ->
            model ! []


updateTopLevel : Msg -> Model -> TopLevelPage -> ( Model, Cmd Msg )
updateTopLevel msg model page =
    model ! []


updateAppSpecific : Msg -> Model -> AppSpecificPage -> ( Model, Cmd Msg )
updateAppSpecific msg model page =
    model ! []



-- update : Msg -> Model -> ( Model, Cmd Msg )
-- update msg model =
--     case ( msg, model.page ) of
--         ( SetRoute route, _ ) ->
--             let
--                 ( page, cmd ) =
--                     navigateTo route
--             in
--             { model | page = page } ! [ cmd ]
--
--         ( AccountAdminMsg subMsg, AccountAdmin subModel ) ->
--             let
--                 ( updated, cmd ) =
--                     AccountAdmin.update subMsg subModel
--             in
--             { model | page = AccountAdmin updated } ! [ Cmd.map AccountAdminMsg cmd ]
--
--         ( AppAdminMsg subMsg, AppAdmin subModel ) ->
--             let
--                 ( updated, cmd ) =
--                     AppAdmin.update subMsg subModel
--             in
--             { model | page = AppAdmin updated } ! [ Cmd.map AppAdminMsg cmd ]
--
--         ( AppDashMsg subMsg, AppDash subModel ) ->
--             let
--                 ( updated, cmd ) =
--                     AppDash.update subMsg subModel
--             in
--             { model | page = AppDash updated } ! [ Cmd.map AppDashMsg cmd ]
--
--         ( GetAppResponse (Ok app), _ ) ->
--             { model | app = app } ! []
--
--         ( GetAppResponse (Err error), _ ) ->
--             model ! []
--
--         ( GetUserResponse (Ok user), _ ) ->
--             { model | user = user } ! []
--
--         ( GetUserResponse (Err error), _ ) ->
--             model ! []
--
--         ( _, _ ) ->
--             -- Disregard incoming messages that arrived for the wrong page
--             model ! []
---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        Anonymous anonymousPage ->
            Sub.none

        Authenticated authenticatedPage ->
            Sub.batch
                [ userSubscriptions model
                , authenticatedSubscriptions model authenticatedPage
                ]


userSubscriptions : Model -> Sub Msg
userSubscriptions model =
    -- TODO: User level subscriptions
    Sub.none


authenticatedSubscriptions : Model -> AuthenticatedPage -> Sub Msg
authenticatedSubscriptions model page =
    case page of
        TopLevel topLevelPage ->
            topLevelPageSubscriptions model topLevelPage

        AppSpecific appSpecificPage ->
            Sub.batch
                [ appSubscriptions model
                , appSpecificPageSubscriptions model appSpecificPage
                ]


topLevelPageSubscriptions : Model -> TopLevelPage -> Sub Msg
topLevelPageSubscriptions model page =
    Sub.none


appSubscriptions : Model -> Sub Msg
appSubscriptions model =
    -- TODO: App level subscriptions
    Sub.none


appSpecificPageSubscriptions : Model -> AppSpecificPage -> Sub Msg
appSpecificPageSubscriptions model page =
    case page of
        AppDash subModel ->
            Sub.map AppDashMsg <| AppDash.subscriptions subModel

        _ ->
            Sub.none



---- VIEW ----


view : Model -> Html Msg
view model =
    case model.page of
        Login ->
            viewStandalone <| div [] [ text "Not implemented" ]

        NotFound ->
            viewStandalone <| div [] [ text "Not found!" ]

        _ ->
            viewPage model


viewStandalone : Html Msg -> Html Msg
viewStandalone inner =
    div [ class "static" ] [ inner ]


viewPage : Model -> Html Msg
viewPage model =
    let
        appPages =
            case model.app of
                Just app ->
                    viewAppPages model app

                Nothing ->
                    div [] [ text "Loading..." ]

        activePage =
            case model.page of
                Home ->
                    div [] []

                Download ->
                    div [] []

                NewApp ->
                    div [] []

                AppDash subModel ->
                    Html.map AppDashMsg <| AppDash.view subModel

                AppAdmin subModel ->
                    Html.map AppAdminMsg <| AppAdmin.view subModel model.app

                AccountAdmin subModel ->
                    Html.map AccountAdminMsg <| AccountAdmin.view subModel model.user

                TeamAdmin ->
                    div [] []
    in
    div [ class "dashboard" ]
        [ TopNav.view model.topNav AccountMenu.view
        , activePage
        ]


viewAppPages : Model -> App -> Html Msg
viewAppPages model app =
    case model.page of
        AppDash subModel ->
            Html.map AppDashMsg <| AppDash.view subModel

        AppAdmin subModel ->
            Html.map AppAdminMsg <| AppAdmin.view subModel app

        _ ->
            div [] []



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
