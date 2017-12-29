module Page.Dashboard exposing (..)

import Data.App as App exposing (App)
import Data.User as User exposing (User)
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Http
import Page.Dashboard.AccountAdmin as AccountAdmin
import Page.Dashboard.App as App
import UrlParser as Url exposing ((</>))
import View.AccountMenu as AccountMenu
import View.TopNav as TopNav


-- MODEL


type alias Model =
    { page : Page
    , user : User
    }


type Page
    = Home
    | App App.Model
    | NewApp
    | AccountAdmin AccountAdmin.Model
    | TeamAdmin
    | Download


init : ( Model, Cmd Msg )
init =
    { page = Home
    , user = User.initialModel
    }
        ! [ -- TODO: Don't hardcode fetching the user
            User.getUser "190e0469-08a5-47b5-a78b-c88221df3067" GetUserResponse
          ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ userSubscriptions model
        , pageSubscriptions model.page
        ]


userSubscriptions : Model -> Sub Msg
userSubscriptions model =
    -- TODO: User level subscriptions
    Sub.none


pageSubscriptions : Page -> Sub Msg
pageSubscriptions page =
    case page of
        App subModel ->
            Sub.map AppMsg <| App.subscriptions subModel

        _ ->
            Sub.none



-- ROUTING
-- navigateTo : Route -> Model -> ( Model, Cmd Msg )
-- navigateTo route model =
--     case ( route, model.page ) of
--         -- If we are already on the app page, then this is a subroute
--         ( AppRoute appId subRoute, App subModel ) ->
--             let
--                 ( app, appCmd ) =
--                     App.update (App.RouteChange subRoute) subModel
--             in
--             { model | page = App app } ! [ Cmd.map AppMsg appCmd ]
--
--         ( AppRoute appId subRoute, _ ) ->
--             let
--                 ( initApp, initCmd ) =
--                     App.init appId
--
--                 ( app, dashCmd ) =
--                     App.update (App.RouteChange subRoute) initApp
--             in
--             { model | page = App app } ! [ Cmd.map AppMsg initCmd, Cmd.map AppMsg dashCmd ]
--
--         ( HomeRoute, _ ) ->
--             { model | page = Home } ! []
--
--         ( NewAppRoute, _ ) ->
--             { model | page = NewApp } ! []
--
--         ( AccountAdminRoute, _ ) ->
--             let
--                 ( initAccountAdmin, cmd ) =
--                     AccountAdmin.init
--             in
--             { model | page = AccountAdmin initAccountAdmin } ! [ Cmd.map AccountAdminMsg cmd ]
--
--         ( TeamAdminRoute teamId, _ ) ->
--             { model | page = TeamAdmin } ! []
--
--         ( DownloadRoute, _ ) ->
--             { model | page = Download } ! []
--
-- UPDATE


type Msg
    = RouteChange Page
    | AppMsg App.Msg
    | AccountAdminMsg AccountAdmin.Msg
    | GetUserResponse (Result Http.Error User)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( RouteChange page, _ ) ->
            -- navigateTo subRoute model
            model ! []

        ( AppMsg subMsg, App subModel ) ->
            let
                ( updated, cmd ) =
                    App.update subMsg subModel
            in
            { model | page = App updated } ! [ Cmd.map AppMsg cmd ]

        ( AccountAdminMsg subMsg, AccountAdmin subModel ) ->
            let
                ( updated, cmd ) =
                    AccountAdmin.update subMsg subModel
            in
            { model | page = AccountAdmin updated } ! [ Cmd.map AccountAdminMsg cmd ]

        ( GetUserResponse (Ok user), _ ) ->
            { model | user = user } ! []

        ( GetUserResponse (Err error), _ ) ->
            model ! []

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            model ! []



-- VIEW


view : Model -> TopNav.LogoPaths r -> Html Msg
view model logoPaths =
    let
        page =
            case model.page of
                Home ->
                    Html.div [] [ Html.text "Dashboard home not implemented" ]

                App subModel ->
                    Html.map AppMsg <| App.view subModel

                NewApp ->
                    Html.div [] [ Html.text "New app not implemented" ]

                AccountAdmin subModel ->
                    Html.map AccountAdminMsg <| AccountAdmin.view subModel model.user

                TeamAdmin ->
                    Html.div [] [ Html.text "Team admin not implemented" ]

                Download ->
                    Html.div [] [ Html.text "Download not implemented" ]
    in
    div [ class "dashboard" ]
        [ TopNav.view logoPaths AccountMenu.view
        , page
        ]
