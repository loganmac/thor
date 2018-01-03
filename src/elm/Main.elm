module Main exposing (..)

import Data.App as App exposing (App)
import Data.Team as Team
import Data.User as User exposing (User)
import Html exposing (Html, div)
import Html.Attributes exposing (class)
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
import View.AccountMenu as AccountMenu
import View.NotFound as NotFound
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


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        ( dashboard, cmd ) =
            Dashboard.init
    in
    navigateTo (Route.parseRoute location)
        { page = Authed <| DashPage <| Dashboard dashboard
        , flags = flags
        , user = Nothing
        , app = Nothing
        }



---- ROUTING ----


type Page
    = Unauthed UnauthedPage
    | Authed AuthedPage



-- Pages that don't require authentication


type UnauthedPage
    = NotFound
    | Login Login.Model
    | Register Register.Model
    | ForgotPassword ForgotPassword.Model



-- Authenticated pages


type AuthedPage
    = AppManagement App.Id AppPage
    | TeamManagement Team.Id TeamPage
    | UserManagement UserPage
    | DashPage DashboardPage



-- Dashboard


type DashboardPage
    = Dashboard Dashboard.Model
    | Download Download.Model
    | NewApp NewApp.Model



-- App management


type AppPage
    = AppDash AppDash.Model
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


type TeamPage
    = TeamInfo TeamInfo.Model
    | TeamSupport TeamSupport.Model
    | TeamBilling TeamBilling.Model
    | TeamPlan TeamPlan.Model
    | TeamMembers TeamMembers.Model
    | TeamAppGroups TeamAppGroups.Model
    | TeamHosting TeamHosting.Model
    | TeamDelete TeamDelete.Model



-- User management


type UserPage
    = UserInfo UserInfo.Model
    | UserSupport UserSupport.Model
    | UserBilling UserBilling.Model
    | UserPlan UserPlan.Model
    | UserHosting UserHosting.Model
    | UserTeams UserTeams.Model
    | UserDelete UserDelete.Model


navigateTo : Route -> Model -> ( Model, Cmd Msg )
navigateTo route model =
    case route of
        -- TOP LEVEL
        Route.NotFound ->
            { model | page = Unauthed <| NotFound } ! []

        Route.Login ->
            { model | page = Unauthed <| Login {} } ! []

        Route.Register ->
            { model | page = Unauthed <| Register {} } ! []

        Route.ForgotPassword ->
            { model | page = Unauthed <| ForgotPassword {} } ! []

        Route.Dashboard ->
            let
                ( dashboard, cmd ) =
                    Dashboard.init
            in
            { model | page = Authed <| DashPage <| Dashboard dashboard }
                ! [ User.getUser "190e0469-08a5-47b5-a78b-c88221df3067" GetUserResponse
                  , Cmd.map DashboardMsg cmd
                  ]

        Route.Download ->
            { model | page = Authed <| DashPage <| Download {} } ! []

        Route.NewApp ->
            { model | page = Authed <| DashPage <| NewApp {} } ! []

        -- APP MANAGEMENT
        Route.AppDash appId ->
            let
                ( appDash, cmd ) =
                    AppDash.init
            in
            { model | page = Authed <| AppManagement appId <| AppDash appDash }
                ! [ Cmd.map AppDashMsg cmd ]

        Route.AppLogs appId ->
            { model | page = Authed <| AppManagement appId <| AppLogs {} } ! []

        Route.AppHistory appId ->
            { model | page = Authed <| AppManagement appId <| AppHistory {} } ! []

        Route.AppDns appId ->
            { model | page = Authed <| AppManagement appId <| AppDns {} } ! []

        Route.AppCertificates appId ->
            { model | page = Authed <| AppManagement appId <| AppCertificates {} } ! []

        Route.AppEvars appId ->
            { model | page = Authed <| AppManagement appId <| AppEvars {} } ! []

        Route.AppBoxfile appId ->
            { model | page = Authed <| AppManagement appId <| AppBoxfile {} } ! []

        Route.AppInfo appId ->
            { model | page = Authed <| AppManagement appId <| AppInfo {} } ! []

        Route.AppOwnership appId ->
            { model | page = Authed <| AppManagement appId <| AppOwnership {} } ! []

        Route.AppDeploy appId ->
            { model | page = Authed <| AppManagement appId <| AppDeploy {} } ! []

        Route.AppUpdate appId ->
            { model | page = Authed <| AppManagement appId <| AppUpdate {} } ! []

        Route.AppSecurity appId ->
            { model | page = Authed <| AppManagement appId <| AppSecurity {} } ! []

        Route.AppDelete appId ->
            { model | page = Authed <| AppManagement appId <| AppDelete {} } ! []

        -- TEAM MANAGEMENT
        Route.TeamInfo teamId ->
            { model | page = Authed <| TeamManagement teamId <| TeamInfo {} } ! []

        Route.TeamSupport teamId ->
            { model | page = Authed <| TeamManagement teamId <| TeamSupport {} } ! []

        Route.TeamBilling teamId ->
            { model | page = Authed <| TeamManagement teamId <| TeamBilling {} } ! []

        Route.TeamPlan teamId ->
            { model | page = Authed <| TeamManagement teamId <| TeamPlan {} } ! []

        Route.TeamMembers teamId ->
            { model | page = Authed <| TeamManagement teamId <| TeamMembers {} } ! []

        Route.TeamAppGroups teamId ->
            { model | page = Authed <| TeamManagement teamId <| TeamAppGroups {} } ! []

        Route.TeamHosting teamId ->
            { model | page = Authed <| TeamManagement teamId <| TeamHosting {} } ! []

        Route.TeamDelete teamId ->
            { model | page = Authed <| TeamManagement teamId <| TeamDelete {} } ! []

        -- USER MANAGEMENT
        Route.UserInfo ->
            { model | page = Authed <| UserManagement <| UserInfo {} } ! []

        Route.UserSupport ->
            { model | page = Authed <| UserManagement <| UserSupport {} } ! []

        Route.UserBilling ->
            { model | page = Authed <| UserManagement <| UserBilling {} } ! []

        Route.UserPlan ->
            { model | page = Authed <| UserManagement <| UserPlan {} } ! []

        Route.UserHosting ->
            { model | page = Authed <| UserManagement <| UserHosting {} } ! []

        Route.UserTeams ->
            { model | page = Authed <| UserManagement <| UserTeams {} } ! []

        Route.UserDelete ->
            { model | page = Authed <| UserManagement <| UserDelete {} } ! []



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



-- update : Msg -> Model -> ( Model, Cmd Msg )
-- update msg model =
--     case ( msg, model.page ) of
--         ( RouteChange route, _ ) ->
--             navigateTo route model
--
--         ( LoginMsg subMsg, Login subModel ) ->
--             model ! []
--
--         ( DashboardMsg subMsg, Dashboard subModel ) ->
--             let
--                 ( updated, cmd ) =
--                     Dashboard.update subMsg subModel
--             in
--             { model | page = Dashboard updated } ! [ Cmd.map DashboardMsg cmd ]
--
--         ( GetUserResponse (Ok user), _ ) ->
--             { model | user = Just user } ! []
--
--         ( GetUserResponse (Err error), _ ) ->
--             model ! []
--
--         ( _, _ ) ->
--             -- Disregard incoming messages that arrived for the wrong page
--             model ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    model ! []



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        Unauthed unAuthedPage ->
            Sub.none

        Authed authedPage ->
            Sub.batch
                [ -- TODO: user-level subscription
                  authedSubscriptions authedPage
                ]


authedSubscriptions : AuthedPage -> Sub Msg
authedSubscriptions page =
    case page of
        AppManagement appId page ->
            -- TODO: app-level subscription
            Sub.none

        _ ->
            Sub.none



---- VIEW ----


view : Model -> Html Msg
view model =
    case model.page of
        Unauthed page ->
            div [ class "unauthed-page" ]
                [ viewUnauthedPage page
                ]

        Authed page ->
            div [ class "authed-page" ]
                [ TopNav.view model.flags AccountMenu.view
                , viewAuthedPage page
                ]


viewUnauthedPage : UnauthedPage -> Html Msg
viewUnauthedPage page =
    case page of
        NotFound ->
            NotFound.view (RouteChange <| Route.Dashboard)

        Login submodel ->
            Html.map LoginMsg <| Login.view submodel

        Register submodel ->
            Html.map RegisterMsg <| Register.view submodel

        ForgotPassword submodel ->
            Html.map ForgotPasswordMsg <| ForgotPassword.view submodel


viewAuthedPage : AuthedPage -> Html Msg
viewAuthedPage page =
    case page of
        AppManagement idApp page ->
            viewAppPage page

        TeamManagement idTeam page ->
            viewTeamPage page

        UserManagement page ->
            viewUserPage page

        DashPage page ->
            viewDashboardPage page


viewAppPage : AppPage -> Html Msg
viewAppPage page =
    case page of
        AppDash submodel ->
            Html.map AppDashMsg <| AppDash.view submodel

        AppLogs submodel ->
            Html.map AppLogsMsg <| AppLogs.view submodel

        AppHistory submodel ->
            Html.map AppHistoryMsg <| AppHistory.view submodel

        AppDns submodel ->
            Html.map AppDnsMsg <| AppDns.view submodel

        AppCertificates submodel ->
            Html.map AppCertificatesMsg <| AppCertificates.view submodel

        AppEvars submodel ->
            Html.map AppEvarsMsg <| AppEvars.view submodel

        AppBoxfile submodel ->
            Html.map AppBoxfileMsg <| AppBoxfile.view submodel

        AppInfo submodel ->
            Html.map AppInfoMsg <| AppInfo.view submodel

        AppOwnership submodel ->
            Html.map AppOwnershipMsg <| AppOwnership.view submodel

        AppDeploy submodel ->
            Html.map AppDeployMsg <| AppDeploy.view submodel

        AppUpdate submodel ->
            Html.map AppUpdateMsg <| AppUpdate.view submodel

        AppSecurity submodel ->
            Html.map AppSecurityMsg <| AppSecurity.view submodel

        AppDelete submodel ->
            Html.map AppDeleteMsg <| AppDelete.view submodel


viewTeamPage : TeamPage -> Html Msg
viewTeamPage page =
    case page of
        TeamInfo submodel ->
            Html.map TeamInfoMsg <| TeamInfo.view submodel

        TeamSupport submodel ->
            Html.map TeamSupportMsg <| TeamSupport.view submodel

        TeamBilling submodel ->
            Html.map TeamBillingMsg <| TeamBilling.view submodel

        TeamPlan submodel ->
            Html.map TeamPlanMsg <| TeamPlan.view submodel

        TeamMembers submodel ->
            Html.map TeamMembersMsg <| TeamMembers.view submodel

        TeamAppGroups submodel ->
            Html.map TeamAppGroupsMsg <| TeamAppGroups.view submodel

        TeamHosting submodel ->
            Html.map TeamHostingMsg <| TeamHosting.view submodel

        TeamDelete submodel ->
            Html.map TeamDeleteMsg <| TeamDelete.view submodel


viewUserPage : UserPage -> Html Msg
viewUserPage page =
    case page of
        UserInfo submodel ->
            Html.map UserInfoMsg <| UserInfo.view submodel

        UserSupport submodel ->
            Html.map UserSupportMsg <| UserSupport.view submodel

        UserBilling submodel ->
            Html.map UserBillingMsg <| UserBilling.view submodel

        UserPlan submodel ->
            Html.map UserPlanMsg <| UserPlan.view submodel

        UserHosting submodel ->
            Html.map UserHostingMsg <| UserHosting.view submodel

        UserTeams submodel ->
            Html.map UserTeamsMsg <| UserTeams.view submodel

        UserDelete submodel ->
            Html.map UserDeleteMsg <| UserDelete.view submodel


viewDashboardPage : DashboardPage -> Html Msg
viewDashboardPage page =
    case page of
        Dashboard submodel ->
            Html.map DashboardMsg <| Dashboard.view submodel

        Download submodel ->
            Html.map DownloadMsg <| Download.view submodel

        NewApp submodel ->
            Html.map NewAppMsg <| NewApp.view submodel



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Navigation.programWithFlags (Route.parseRoute >> RouteChange)
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
