module Main exposing (..)

import Data.App as App exposing (App)
import Data.User as User exposing (User)
import Flag
import Html exposing (Html, div, h1, img, text)
import Http
import Navigation exposing (Location)
import Page.App.Boxfile as AppBoxfile
import Page.App.Certificates as AppCertificates
import Page.App.Dash as AppDash
import Page.App.Delete as AppDelete
import Page.App.Deploy as AppDeploy
import Page.App.Dns as AppDns
import Page.App.Evars as AppEvars
import Page.App.History as AppHistory
import Page.App.Info as AppInfo
import Page.App.Logs as AppLogs
import Page.App.Ownership as AppOwnership
import Page.App.Security as AppSecurity
import Page.App.Update as AppUpdate
import Page.Auth.ForgotPassword as ForgotPassword
import Page.Auth.Login as Login
import Page.Auth.Register as Register
import Page.Dashboard as Dashboard
import Page.Download as Download
import Page.NewApp as NewApp
import Page.Team.AppGroups as TeamAppGroups
import Page.Team.Billing as TeamBilling
import Page.Team.Delete as TeamDelete
import Page.Team.Hosting as TeamHosting
import Page.Team.Info as TeamInfo
import Page.Team.Members as TeamMembers
import Page.Team.Plan as TeamPlan
import Page.Team.Support as TeamSupport
import Page.User.Billing as UserBilling
import Page.User.Delete as UserDelete
import Page.User.Hosting as UserHosting
import Page.User.Info as UserInfo
import Page.User.Plan as UserPlan
import Page.User.Support as UserSupport
import Page.User.Teams as UserTeams
import Route exposing (Route)
import View.NotFound as NotFound


---- MODEL ----


type alias Model =
    { page : Page
    , flags : Flag.Flags
    , user : Maybe User
    , app : Maybe App
    }


type Page
    = -- Top level
      NotFound
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


init : Flag.Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        ( dashboard, cmd ) =
            Dashboard.init
    in
    navigateTo (Route.parseRoute location)
        { page = Dashboard dashboard
        , flags = flags
        , user = Nothing
        , app = Nothing
        }



---- ROUTING ----


navigateTo : Route -> Model -> ( Model, Cmd Msg )
navigateTo route model =
    case route of
        -- TOP LEVEL
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

        Route.Download ->
            { model | page = Download {} } ! []

        Route.NewApp ->
            { model | page = NewApp {} } ! []

        -- APP MANAGEMENT
        Route.AppDash appId ->
            let
                ( appDash, cmd ) =
                    AppDash.init
            in
            { model | page = AppDash appDash } ! [ Cmd.map AppDashMsg cmd ]

        Route.AppLogs idApp ->
            { model | page = AppLogs {} } ! []

        Route.AppHistory idApp ->
            { model | page = AppHistory {} } ! []

        Route.AppDns appId ->
            { model | page = AppDns {} } ! []

        Route.AppCertificates appId ->
            { model | page = AppCertificates {} } ! []

        Route.AppEvars appId ->
            { model | page = AppEvars {} } ! []

        Route.AppBoxfile appId ->
            { model | page = AppBoxfile {} } ! []

        Route.AppInfo appId ->
            { model | page = AppInfo {} } ! []

        Route.AppOwnership appId ->
            { model | page = AppOwnership {} } ! []

        Route.AppDeploy appId ->
            { model | page = AppDeploy {} } ! []

        Route.AppUpdate appId ->
            { model | page = AppUpdate {} } ! []

        Route.AppSecurity appId ->
            { model | page = AppSecurity {} } ! []

        Route.AppDelete appId ->
            { model | page = AppDelete {} } ! []

        -- TEAM MANAGEMENT
        Route.TeamInfo teamId ->
            { model | page = TeamInfo {} } ! []

        Route.TeamSupport teamId ->
            { model | page = TeamSupport {} } ! []

        Route.TeamBilling teamId ->
            { model | page = TeamBilling {} } ! []

        Route.TeamPlan teamId ->
            { model | page = TeamPlan {} } ! []

        Route.TeamMembers teamId ->
            { model | page = TeamMembers {} } ! []

        Route.TeamAppGroups teamId ->
            { model | page = TeamAppGroups {} } ! []

        Route.TeamHosting teamId ->
            { model | page = TeamHosting {} } ! []

        Route.TeamDelete teamId ->
            { model | page = TeamDelete {} } ! []

        -- USER MANAGEMENT
        Route.UserInfo ->
            { model | page = UserInfo {} } ! []

        Route.UserSupport ->
            { model | page = UserSupport {} } ! []

        Route.UserBilling ->
            { model | page = UserBilling {} } ! []

        Route.UserPlan ->
            { model | page = UserPlan {} } ! []

        Route.UserHosting ->
            { model | page = UserHosting {} } ! []

        Route.UserTeams ->
            { model | page = UserTeams {} } ! []

        Route.UserDelete ->
            { model | page = UserDelete {} } ! []



---- UPDATE ----


type Msg
    = RouteChange Route
    | LoginMsg Login.Msg
    | RegisterMsg Register.Msg
    | ForgotPasswordMsg ForgotPassword.Msg
      -- Authenticated/dashboard routes
    | DashboardMsg Dashboard.Msg
    | DownloadMsg Download.Msg
    | NewAppMsg NewApp.Msg
      -- App management
    | AppDashMsg AppDash.Msg
    | AppLogsMsg AppLogs.Msg
    | AppHistoryMsg AppHistory.Msg
    | AppDnsMsg AppDns.Msg
    | AppCertificatesMsg AppCertificates.Msg
    | AppEvarsMsg AppEvars.Msg
    | AppBoxfileMsg AppBoxfile.Msg
    | AppInfoMsg AppInfo.Msg
    | AppOwnershipMsg AppOwnership.Msg
    | AppDeployMsg AppDeploy.Msg
    | AppUpdateMsg AppUpdate.Msg
    | AppSecurityMsg AppSecurity.Msg
    | AppDeleteMsg AppDelete.Msg
      -- Team management
    | TeamInfoMsg TeamInfo.Msg
    | TeamSupportMsg TeamSupport.Msg
    | TeamBillingMsg TeamBilling.Msg
    | TeamPlanMsg TeamPlan.Msg
    | TeamMembersMsg TeamMembers.Msg
    | TeamAppGroupsMsg TeamAppGroups.Msg
    | TeamHostingMsg TeamHosting.Msg
    | TeamDeleteMsg TeamDelete.Msg
      -- User management
    | UserInfoMsg UserInfo.Msg
    | UserSupportMsg UserSupport.Msg
    | UserBillingMsg UserBilling.Msg
    | UserPlanMsg UserPlan.Msg
    | UserHostingMsg UserHosting.Msg
    | UserTeamsMsg UserTeams.Msg
    | UserDeleteMsg UserDelete.Msg
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
        NotFound ->
            NotFound.view (RouteChange <| Route.Dashboard)

        Login submodel ->
            Html.map LoginMsg <| Login.view submodel

        Register submodel ->
            Html.map RegisterMsg <| Register.view submodel

        ForgotPassword submodel ->
            Html.map ForgotPasswordMsg <| ForgotPassword.view submodel

        Dashboard submodel ->
            Html.map DashboardMsg <| Dashboard.view model.flags submodel

        Download submodel ->
            Html.map DownloadMsg <| Download.view model.flags submodel

        NewApp submodel ->
            Html.map NewAppMsg <| NewApp.view model.flags submodel

        AppDash submodel ->
            Html.map AppDashMsg <| AppDash.view model.flags submodel

        AppLogs submodel ->
            Html.map AppLogsMsg <| AppLogs.view model.flags submodel

        AppHistory submodel ->
            Html.map AppHistoryMsg <| AppHistory.view model.flags submodel

        AppDns submodel ->
            Html.map AppDnsMsg <| AppDns.view model.flags submodel

        AppCertificates submodel ->
            Html.map AppCertificatesMsg <| AppCertificates.view model.flags submodel

        AppEvars submodel ->
            Html.map AppEvarsMsg <| AppEvars.view model.flags submodel

        AppBoxfile submodel ->
            Html.map AppBoxfileMsg <| AppBoxfile.view model.flags submodel

        AppInfo submodel ->
            Html.map AppInfoMsg <| AppInfo.view model.flags submodel

        AppOwnership submodel ->
            Html.map AppOwnershipMsg <| AppOwnership.view model.flags submodel

        AppDeploy submodel ->
            Html.map AppDeployMsg <| AppDeploy.view model.flags submodel

        AppUpdate submodel ->
            Html.map AppUpdateMsg <| AppUpdate.view model.flags submodel

        AppSecurity submodel ->
            Html.map AppSecurityMsg <| AppSecurity.view model.flags submodel

        AppDelete submodel ->
            Html.map AppDeleteMsg <| AppDelete.view model.flags submodel

        TeamInfo submodel ->
            Html.map TeamInfoMsg <| TeamInfo.view model.flags submodel

        TeamSupport submodel ->
            Html.map TeamSupportMsg <| TeamSupport.view model.flags submodel

        TeamBilling submodel ->
            Html.map TeamBillingMsg <| TeamBilling.view model.flags submodel

        TeamPlan submodel ->
            Html.map TeamPlanMsg <| TeamPlan.view model.flags submodel

        TeamMembers submodel ->
            Html.map TeamMembersMsg <| TeamMembers.view model.flags submodel

        TeamAppGroups submodel ->
            Html.map TeamAppGroupsMsg <| TeamAppGroups.view model.flags submodel

        TeamHosting submodel ->
            Html.map TeamHostingMsg <| TeamHosting.view model.flags submodel

        TeamDelete submodel ->
            Html.map TeamDeleteMsg <| TeamDelete.view model.flags submodel

        UserInfo submodel ->
            Html.map UserInfoMsg <| UserInfo.view model.flags submodel

        UserSupport submodel ->
            Html.map UserSupportMsg <| UserSupport.view model.flags submodel

        UserBilling submodel ->
            Html.map UserBillingMsg <| UserBilling.view model.flags submodel

        UserPlan submodel ->
            Html.map UserPlanMsg <| UserPlan.view model.flags submodel

        UserHosting submodel ->
            Html.map UserHostingMsg <| UserHosting.view model.flags submodel

        UserTeams submodel ->
            Html.map UserTeamsMsg <| UserTeams.view model.flags submodel

        UserDelete submodel ->
            Html.map UserDeleteMsg <| UserDelete.view model.flags submodel



---- PROGRAM ----


main : Program Flag.Flags Model Msg
main =
    Navigation.programWithFlags (Route.parseRoute >> RouteChange)
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
