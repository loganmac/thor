module Main exposing (..)

import Data.App as App exposing (App)
import Data.User as User exposing (User)
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (class)
import Http
import Navigation exposing (Location)
import Page.AccountAdmin as AccountAdmin
import Page.Auth.ForgotPassword as ForgotPassword
import Page.Auth.Login as Login
import Page.Auth.Register as Register
import Page.Dashboard as Dashboard
import Page.NotFound
import Route exposing (Route)
import View.AccountMenu as AccountMenu
import View.TopNav as TopNav


---- MODEL ----


type alias Model =
    { page : Page
    , flags : Flags
    , user : Maybe User
    , app : Maybe App
    }


type alias Flags =
    { logoPath : String
    , homeLogoPath : String
    , supportLogoPath : String
    }


type Page
    = -- Top level
      NotFound
    | Loading
    | Login Login.Model
    | Register Register.Model
    | ForgotPassword ForgotPassword.Model
      -- Authenticated/dashboard routes
    | Dashboard Dashboard.Model
    | Download Download.Model
    | NewApp NewApp.Model
      -- App management
    | AppDash AppDash.Model
    | AppLogs AppLogs.Model
    | AppHistory AppHistory.Model
    | AppDns AppDns.Model
    | AppCertificates AppCertificates.Model
    | AppEvars AppEvars.Model
    | AppBoxfile AppBoxfile.Model
    | AppInfo AppInfo.Model
    | AppOwnership AppOwnership.Model
    | AppDeploy AppDeploy.Model
    | AppUpdate AppUpdate.Model
    | AppSecurity AppSecurity.Model
    | AppDelete AppDelete.Model
      -- Team management
    | TeamInfo TeamInfo.Model
    | TeamSupport TeamSupport.Model
    | TeamBilling TeamBilling.Model
    | TeamPlan TeamPlan.Model
    | TeamMembers TeamMembers.Model
    | TeamAppGroups TeamAppGroups.Model
    | TeamHosting TeamHosting.Model
    | TeamDelete TeamDelete.Model
      -- User management
    | UserInfo UserInfo.Model
    | UserSupport UserSupport.Model
    | UserBilling UserBilling.Model
    | UserPlan UserPlan.Model
    | UserHosting UserHosting.Model
    | UserTeams UserTeams.Model
    | UserDelete UserDelete.Model


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    navigateTo (Route.parseRoute location)
        { page = Loading
        , flags = flags
        , user = Nothing
        , app = Nothing
        }



---- ROUTING ----


navigateTo : Route -> Model -> ( Model, Cmd Msg )
navigateTo route model =
    case route of
        Route.NotFound ->
            { model | page = NotFound } ! []

        Route.Login ->
            { model | page = Login {} } ! []

        Route.Register ->
            { model | page = Register {} } ! []

        Route.ForgotPassword ->
            { model | page = ForgotPassword {} } ! []

        Route.Dashboard ->
            let
                ( dashboard, cmd ) =
                    Dashboard.init
            in
            { model | page = Dashboard dashboard }
                ! [ User.getUser "190e0469-08a5-47b5-a78b-c88221df3067" GetUserResponse
                  , Cmd.map DashboardMsg cmd
                  ]

        Route.NewApp ->
            { model | page = NewApp {} } ! []

        Route.TeamAdmin teamId ->
            { model | page = TeamAdmin {} } ! []

        Route.UserInfo ->
            { model | page = Register {} } ! []

        Route.UserSupport ->
            { model | page = Register {} } ! []

        Route.UserBilling ->
            { model | page = Register {} } ! []

        Route.UserAccountPlan ->
            { model | page = Register {} } ! []

        Route.UserHostingAccounts ->
            { model | page = Register {} } ! []

        Route.UserTeams ->
            { model | page = Register {} } ! []

        Route.UserDelete ->
            { model | page = Register {} } ! []

        Route.Download ->
            { model | page = Register {} } ! []

        Route.AppDash appId ->
            { model | page = Register {} } ! []

        Route.AppHistory appId ->
            { model | page = Register {} } ! []

        Route.AppLogs appId ->
            { model | page = Register {} } ! []

        Route.AppCertificates appId ->
            { model | page = Register {} } ! []

        Route.AppDns appId ->
            { model | page = Register {} } ! []

        Route.AppEvars idApp ->
            { model | page = Register {} } ! []

        Route.AppBoxfile idApp ->
            { model | page = Register {} } ! []

        Route.AppDash idApp ->
            { model | page = Register {} } ! []

        Route.AppDns idApp ->
            { model | page = Register {} } ! []

        Route.AppCertificates idApp ->
            { model | page = Register {} } ! []

        Route.AppHistory idApp ->
            { model | page = Register {} } ! []

        Route.AppLogs idApp ->
            { model | page = Register {} } ! []



---- UPDATE ----


type Msg
    = RouteChange Route
    | LoginMsg Login.Msg
    | DashboardMsg Dashboard.Msg
    | AccountAdminMsg AccountAdmin.Msg
    | GetUserResponse (Result Http.Error User)


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

        ( GetUserResponse (Ok user), _ ) ->
            { model | user = Just user } ! []

        ( GetUserResponse (Err error), _ ) ->
            model ! []

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            model ! []

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            model ! []



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        Dashboard subModel ->
            userSubscriptions subModel

        _ ->
            Sub.none


userSubscriptions : Dashboard.Model -> Sub Msg
userSubscriptions model =
    Sub.none



---- VIEW ----


view : Model -> Html Msg
view model =
    case model.page of
        Loading ->
            div [] [ text "Loading..." ]

        NotFound ->
            Page.NotFound.view (RouteChange <| Route.Dashboard)

        Login subModel ->
            Html.map LoginMsg <| Login.view subModel

        Dashboard subModel ->
            Html.map DashboardMsg <| Dashboard.view subModel

        NewApp ->
            Html.div [] [ Html.text "New app not implemented" ]

        AccountAdmin subModel ->
            case model.user of
                Nothing ->
                    div [] [ text "Loading..." ]

                Just user ->
                    Html.map AccountAdminMsg <| AccountAdmin.view subModel user

        TeamAdmin ->
            Html.div [] [ Html.text "Team admin not implemented" ]

        Download ->
            Html.div [] [ Html.text "Download not implemented" ]



-- div [ class "dashboard" ]
--     [ TopNav.view model.flags AccountMenu.view
--     , page
--     ]
---- PROGRAM ----


main : Program Flags Model Msg
main =
    Navigation.programWithFlags (Route.parseRoute >> RouteChange)
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
