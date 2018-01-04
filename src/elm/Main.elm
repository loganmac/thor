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
    routeTo (Route.parseRoute location)
        { page = Authed <| DashPage <| Dashboard dashboard
        , flags = flags
        , user = Nothing
        , app = Nothing
        }



---- ROUTING ----


type Page
    = Unauthed UnauthedPage
    | Authed AuthedPage


type UnauthedPage
    = NotFound
    | Login Login.Model
    | Register Register.Model
    | ForgotPassword ForgotPassword.Model


type AuthedPage
    = AppManagement App.Id AppPage
    | TeamManagement Team.Id TeamPage
    | UserManagement UserPage
    | DashPage DashboardPage


type DashboardPage
    = Dashboard Dashboard.Model
    | Download Download.Model
    | NewApp NewApp.Model


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


type TeamPage
    = TeamInfo TeamInfo.Model
    | TeamSupport TeamSupport.Model
    | TeamBilling TeamBilling.Model
    | TeamPlan TeamPlan.Model
    | TeamMembers TeamMembers.Model
    | TeamAppGroups TeamAppGroups.Model
    | TeamHosting TeamHosting.Model
    | TeamDelete TeamDelete.Model


type UserPage
    = UserInfo UserInfo.Model
    | UserSupport UserSupport.Model
    | UserBilling UserBilling.Model
    | UserPlan UserPlan.Model
    | UserHosting UserHosting.Model
    | UserTeams UserTeams.Model
    | UserDelete UserDelete.Model


routeTo : Route -> Model -> ( Model, Cmd Msg )
routeTo route model =
    case route of
        Route.Unauthed subRoute ->
            let
                ( page, cmd ) =
                    routeUnauthed subRoute model
            in
            { model | page = Unauthed page } ! [ cmd ]

        Route.Authed subRoute ->
            let
                ( page, cmd ) =
                    routeAuthed subRoute model
            in
            -- TODO: check authentication, possibly redirect to login
            -- TODO: setup authed subscription here
            { model | page = Authed page }
                ! [ User.getUser "190e0469-08a5-47b5-a78b-c88221df3067" GetUserResponse
                  , cmd
                  ]


routeUnauthed : Route.UnauthedRoute -> Model -> ( UnauthedPage, Cmd Msg )
routeUnauthed route model =
    case route of
        Route.NotFound ->
            NotFound ! []

        Route.Login ->
            Login {} ! []

        Route.Register ->
            Register {} ! []

        Route.ForgotPassword ->
            ForgotPassword {} ! []


routeAuthed : Route.AuthedRoute -> Model -> ( AuthedPage, Cmd Msg )
routeAuthed route model =
    case route of
        Route.Dash subRoute ->
            let
                ( page, cmd ) =
                    routeDash subRoute model
            in
            DashPage page ! [ cmd ]

        Route.App appId subRoute ->
            let
                ( page, cmd ) =
                    routeApp subRoute model
            in
            -- TODO: setup app subscription here
            AppManagement appId page ! [ cmd ]

        Route.Team teamId subRoute ->
            let
                ( page, cmd ) =
                    routeTeam subRoute model
            in
            TeamManagement teamId page ! [ cmd ]

        Route.User subRoute ->
            let
                ( page, cmd ) =
                    routeUser subRoute model
            in
            UserManagement page ! [ cmd ]


routeDash : Route.DashboardRoute -> Model -> ( DashboardPage, Cmd Msg )
routeDash route model =
    case route of
        Route.Dashboard ->
            let
                ( dashboard, cmd ) =
                    Dashboard.init
            in
            Dashboard dashboard
                ! [ Cmd.map DashboardMsg cmd
                  ]

        Route.Download ->
            Download {} ! []

        Route.NewApp ->
            NewApp {} ! []


routeApp : Route.AppRoute -> Model -> ( AppPage, Cmd Msg )
routeApp route model =
    case route of
        Route.AppDash ->
            let
                ( appDash, cmd ) =
                    AppDash.init
            in
            AppDash appDash ! [ Cmd.map AppDashMsg cmd ]

        Route.AppLogs ->
            AppLogs {} ! []

        Route.AppHistory ->
            AppHistory {} ! []

        Route.AppDns ->
            AppDns {} ! []

        Route.AppCertificates ->
            AppCertificates {} ! []

        Route.AppEvars ->
            AppEvars {} ! []

        Route.AppBoxfile ->
            AppBoxfile {} ! []

        Route.AppInfo ->
            AppInfo {} ! []

        Route.AppOwnership ->
            AppOwnership {} ! []

        Route.AppDeploy ->
            AppDeploy {} ! []

        Route.AppUpdate ->
            AppUpdate {} ! []

        Route.AppSecurity ->
            AppSecurity {} ! []

        Route.AppDelete ->
            AppDelete {} ! []


routeTeam : Route.TeamRoute -> Model -> ( TeamPage, Cmd Msg )
routeTeam route model =
    case route of
        Route.TeamInfo ->
            TeamInfo {} ! []

        Route.TeamSupport ->
            TeamSupport {} ! []

        Route.TeamBilling ->
            TeamBilling {} ! []

        Route.TeamPlan ->
            TeamPlan {} ! []

        Route.TeamMembers ->
            TeamMembers {} ! []

        Route.TeamAppGroups ->
            TeamAppGroups {} ! []

        Route.TeamHosting ->
            TeamHosting {} ! []

        Route.TeamDelete ->
            TeamDelete {} ! []


routeUser : Route.UserRoute -> Model -> ( UserPage, Cmd Msg )
routeUser route model =
    case route of
        Route.UserInfo ->
            UserInfo {} ! []

        Route.UserSupport ->
            UserSupport {} ! []

        Route.UserBilling ->
            UserBilling {} ! []

        Route.UserPlan ->
            UserPlan {} ! []

        Route.UserHosting ->
            UserHosting {} ! []

        Route.UserTeams ->
            UserTeams {} ! []

        Route.UserDelete ->
            UserDelete {} ! []



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



-- TODO: split this out into a real update function


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( RouteChange route, _ ) ->
            routeTo route model

        -- ( LoginMsg subMsg, Login subModel ) ->
        --     model ! []
        --
        -- ( DashboardMsg subMsg, Dashboard subModel ) ->
        --     let
        --         ( updated, cmd ) =
        --             Dashboard.update subMsg subModel
        --     in
        --     { model | page = Dashboard updated } ! [ Cmd.map DashboardMsg cmd ]
        --
        -- ( GetUserResponse (Ok user), _ ) ->
        --     { model | user = Just user } ! []
        --
        -- ( GetUserResponse (Err error), _ ) ->
        --     model ! []
        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
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
            NotFound.view
                (RouteChange <| Route.Authed <| Route.Dash <| Route.Dashboard)

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
