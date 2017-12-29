module Main exposing (..)

import Html exposing (Html, div, h1, img, text)
import Navigation exposing (Location)
import Page.Dashboard as Dashboard
import Page.Login as Login
import Page.NotFound
import UrlParser as Url exposing ((</>))


---- MODEL ----


type alias Model =
    { page : Page
    , flags : Flags
    }


type alias Flags =
    { logoPath : String
    , homeLogoPath : String
    , supportLogoPath : String
    }


type Page
    = NotFound
    | Loading
    | Login Login.Model
    | Dashboard Dashboard.Model


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    navigateTo (parseRoute location)
        { page = Loading
        , flags = flags
        }



---- ROUTING ----


type Route
    = DashboardRoute Dashboard.Route
    | LoginRoute String
    | NotFoundRoute


routes : Url.Parser (Route -> a) a
routes =
    Url.oneOf
        [ Url.map LoginRoute (Url.s "login" </> Url.string)
        , Url.map NotFoundRoute (Url.s "not-found")
        , Url.map DashboardRoute Dashboard.routeParser
        ]


parseRoute : Location -> Route
parseRoute location =
    if String.isEmpty location.hash then
        DashboardRoute Dashboard.HomeRoute
    else
        case Url.parseHash routes location of
            Just route ->
                route

            Nothing ->
                NotFoundRoute


navigateTo : Route -> Model -> ( Model, Cmd Msg )
navigateTo route model =
    case ( route, model.page ) of
        -- if we are already on the dashboard, then this is a subroute
        ( DashboardRoute subRoute, Dashboard subModel ) ->
            let
                ( dashboard, dashCmd ) =
                    Dashboard.update (Dashboard.RouteChange subRoute) subModel
            in
            { model | page = Dashboard dashboard } ! [ Cmd.map DashboardMsg dashCmd ]

        ( DashboardRoute subRoute, _ ) ->
            let
                ( initDashboard, initCmd ) =
                    Dashboard.init

                ( dashboard, dashCmd ) =
                    Dashboard.update (Dashboard.RouteChange subRoute) initDashboard
            in
            { model | page = Dashboard dashboard }
                ! [ Cmd.map DashboardMsg initCmd
                  , Cmd.map DashboardMsg dashCmd
                  ]

        ( LoginRoute subRoute, _ ) ->
            { model | page = Login {} } ! []

        ( NotFoundRoute, _ ) ->
            { model | page = NotFound } ! []



---- UPDATE ----


type Msg
    = RouteChange Route
    | LoginMsg Login.Msg
    | DashboardMsg Dashboard.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( RouteChange route, _ ) ->
            navigateTo route model

        ( LoginMsg subMsg, Login subModel ) ->
            model ! []

        ( DashboardMsg subMsg, Dashboard subModel ) ->
            let
                ( updated, cmd ) =
                    Dashboard.update subMsg subModel
            in
            { model | page = Dashboard updated } ! [ Cmd.map DashboardMsg cmd ]

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            model ! []



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        Dashboard subModel ->
            Sub.map DashboardMsg <| Dashboard.subscriptions subModel

        _ ->
            Sub.none



---- VIEW ----


view : Model -> Html Msg
view model =
    case model.page of
        Loading ->
            div [] [ text "Loading..." ]

        NotFound ->
            Page.NotFound.view (RouteChange <| DashboardRoute Dashboard.HomeRoute)

        Login subModel ->
            Html.map LoginMsg <| Login.view subModel

        Dashboard subModel ->
            Html.map DashboardMsg <| Dashboard.view subModel model.flags



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Navigation.programWithFlags (parseRoute >> RouteChange)
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
