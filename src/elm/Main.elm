module Main exposing (..)

import Data.App as App exposing (App)
import Data.Team as Team
import Data.User as User exposing (User)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Http
import Json.Decode
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
import Page.NotFound as NotFound
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
import Port
import Route exposing (Route)
import Util
import View.AccountMenu as AccountMenu
import View.Corral as Corral
import View.TopNav as TopNav


---- MODEL ----


type alias Model =
    { page : Page
    , flags : Flags
    , user : Maybe User
    , app : Maybe App
    , activeRoute : Route
    }


type alias Flags =
    { session : Json.Decode.Value
    , logoPath : String
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
        , user = User.fromSession flags.session
        , app = Nothing
        , activeRoute = Route.parseRoute location
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
    = DashPage DashboardPage
    | AppManagement App.Id AppPage
    | TeamManagement Team.Id TeamPage
    | UserManagement UserPage


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
            { model | page = Unauthed page } ! [ Cmd.map UnauthedMsg cmd ]

        Route.Authed subRoute ->
            -- TODO: setup authed subscription here?
            case model.user of
                Just user ->
                    let
                        ( page, cmd ) =
                            routeAuthed subRoute model user
                    in
                    { model | page = Authed page } ! [ Cmd.map AuthedMsg cmd ]

                Nothing ->
                    model ! [ Route.modifyUrl <| Route.Unauthed <| Route.Login ]

        Route.LogOut ->
            { model | user = Nothing }
                ! [ Port.storeSession Nothing
                  , Route.modifyUrl Route.home
                  ]


routeUnauthed : Route.UnauthedRoute -> Model -> ( UnauthedPage, Cmd UnauthedMessage )
routeUnauthed route model =
    case route of
        Route.NotFound ->
            NotFound ! []

        Route.Login ->
            case model.user of
                Just user ->
                    Login Login.init ! [ Route.modifyUrl Route.home ]

                Nothing ->
                    Login Login.init ! []

        Route.Register ->
            Register {} ! []

        Route.ForgotPassword ->
            ForgotPassword {} ! []


routeAuthed : Route.AuthedRoute -> Model -> User -> ( AuthedPage, Cmd AuthedMessage )
routeAuthed route model user =
    case route of
        Route.Dash subRoute ->
            let
                ( page, cmd ) =
                    routeDash subRoute model
            in
            DashPage page ! [ Cmd.map DashMsg cmd ]

        Route.App ((App.Id id) as appId) subRoute ->
            let
                app =
                    Maybe.withDefault App.initialModel model.app

                ( page, cmd ) =
                    routeApp subRoute model

                fetchApp =
                    if app.id == appId then
                        Cmd.none
                    else
                        App.getApp id (Just user.authToken) GetAppResponse
            in
            -- TODO: setup app subscription here?
            AppManagement appId page
                ! [ fetchApp
                  , Cmd.map AppMsg cmd
                  ]

        Route.Team teamId subRoute ->
            let
                ( page, cmd ) =
                    routeTeam subRoute model
            in
            TeamManagement teamId page ! [ Cmd.map TeamMsg cmd ]

        Route.User subRoute ->
            let
                ( page, cmd ) =
                    routeUser subRoute model
            in
            UserManagement page ! [ Cmd.map UserMsg cmd ]


routeDash : Route.DashboardRoute -> Model -> ( DashboardPage, Cmd DashMessage )
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


routeApp : Route.AppRoute -> Model -> ( AppPage, Cmd AppMessage )
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
            let
                ( updated, cmd ) =
                    AppInfo.init
            in
            AppInfo updated ! [ Cmd.map AppInfoMsg cmd ]

        Route.AppOwnership ->
            let
                ( updated, cmd ) =
                    AppOwnership.init
            in
            AppOwnership updated ! [ Cmd.map AppOwnershipMsg cmd ]

        Route.AppDeploy ->
            let
                ( updated, cmd ) =
                    AppDeploy.init
            in
            AppDeploy updated ! [ Cmd.map AppDeployMsg cmd ]

        Route.AppUpdate ->
            let
                ( updated, cmd ) =
                    AppUpdate.init
            in
            AppUpdate updated ! [ Cmd.map AppUpdateMsg cmd ]

        Route.AppSecurity ->
            let
                ( updated, cmd ) =
                    AppSecurity.init
            in
            AppSecurity updated ! [ Cmd.map AppSecurityMsg cmd ]

        Route.AppDelete ->
            let
                ( updated, cmd ) =
                    AppDelete.init
            in
            AppDelete updated ! [ Cmd.map AppDeleteMsg cmd ]


routeTeam : Route.TeamRoute -> Model -> ( TeamPage, Cmd TeamMessage )
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


routeUser : Route.UserRoute -> Model -> ( UserPage, Cmd UserMessage )
routeUser route model =
    case route of
        Route.UserInfo ->
            let
                ( updated, cmd ) =
                    UserInfo.init
            in
            UserInfo updated ! [ Cmd.map UserInfoMsg cmd ]

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
    | GetUserResponse (Result Http.Error User)
    | UnauthedMsg UnauthedMessage
    | AuthedMsg AuthedMessage


type UnauthedMessage
    = LoginMsg Login.Msg
    | RegisterMsg Register.Msg
    | ForgotPasswordMsg ForgotPassword.Msg
    | SetUser User


type AuthedMessage
    = GetAppResponse (Result Http.Error App)
    | DashMsg DashMessage
    | AppMsg AppMessage
    | TeamMsg TeamMessage
    | UserMsg UserMessage


type DashMessage
    = DashboardMsg Dashboard.Msg
    | DownloadMsg Download.Msg
    | NewAppMsg NewApp.Msg


type AppMessage
    = AppDashMsg AppDash.Msg
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


type TeamMessage
    = TeamInfoMsg TeamInfo.Msg
    | TeamSupportMsg TeamSupport.Msg
    | TeamBillingMsg TeamBilling.Msg
    | TeamPlanMsg TeamPlan.Msg
    | TeamMembersMsg TeamMembers.Msg
    | TeamAppGroupsMsg TeamAppGroups.Msg
    | TeamHostingMsg TeamHosting.Msg
    | TeamDeleteMsg TeamDelete.Msg


type UserMessage
    = UserInfoMsg UserInfo.Msg
    | UserSupportMsg UserSupport.Msg
    | UserBillingMsg UserBilling.Msg
    | UserPlanMsg UserPlan.Msg
    | UserHostingMsg UserHosting.Msg
    | UserTeamsMsg UserTeams.Msg
    | UserDeleteMsg UserDelete.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( RouteChange route, _ ) ->
            routeTo route { model | activeRoute = route }

        ( GetUserResponse (Ok user), _ ) ->
            { model | user = Just user } ! []

        ( GetUserResponse (Err error), _ ) ->
            model ! []

        ( AuthedMsg (GetAppResponse (Ok app)), _ ) ->
            { model | app = Just app } ! []

        ( AuthedMsg (GetAppResponse (Err error)), _ ) ->
            -- TODO: Don't swallow error, show error or go
            -- to not found on an invalid url
            model ! [ Navigation.newUrl "#not-found" ]

        ( UnauthedMsg (SetUser user), _ ) ->
            { model | user = Just user }
                ! [ User.storeSession user
                  , Route.modifyUrl Route.home
                  ]

        ( UnauthedMsg subMsg, Unauthed page ) ->
            let
                ( newPage, cmd ) =
                    updateUnauthed subMsg page
            in
            { model | page = Unauthed newPage } ! [ Cmd.map UnauthedMsg cmd ]

        ( AuthedMsg subMsg, Authed page ) ->
            let
                ( newPage, cmd ) =
                    updateAuthed subMsg page (Maybe.withDefault User.initialModel model.user)
            in
            { model | page = Authed newPage } ! [ Cmd.map AuthedMsg cmd ]

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            model ! []


updateUnauthed : UnauthedMessage -> UnauthedPage -> ( UnauthedPage, Cmd UnauthedMessage )
updateUnauthed msg page =
    case ( msg, page ) of
        ( LoginMsg subMsg, Login subModel ) ->
            let
                ( newPage, cmd, maybeUser ) =
                    Login.update subMsg subModel

                setUser =
                    case maybeUser of
                        Just user ->
                            Util.send <| SetUser user

                        Nothing ->
                            Cmd.none
            in
            ( Login newPage, Cmd.batch [ Cmd.map LoginMsg cmd, setUser ] )

        ( RegisterMsg subMsg, Register subModel ) ->
            let
                ( newPage, cmd ) =
                    Register.update subMsg subModel
            in
            ( Register newPage, Cmd.batch [ Cmd.map RegisterMsg cmd ] )

        ( ForgotPasswordMsg subMsg, ForgotPassword subModel ) ->
            let
                ( newPage, cmd ) =
                    ForgotPassword.update subMsg subModel
            in
            ( ForgotPassword newPage, Cmd.batch [ Cmd.map ForgotPasswordMsg cmd ] )

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            ( page, Cmd.none )


updateAuthed : AuthedMessage -> AuthedPage -> User -> ( AuthedPage, Cmd AuthedMessage )
updateAuthed msg page user =
    -- page ! []
    case ( msg, page ) of
        ( DashMsg subMsg, DashPage subPage ) ->
            let
                ( newPage, cmd ) =
                    updateDash subMsg subPage
            in
            DashPage newPage ! [ Cmd.map DashMsg cmd ]

        ( AppMsg subMsg, AppManagement appId subPage ) ->
            let
                ( newPage, cmd ) =
                    updateApp subMsg subPage
            in
            AppManagement appId newPage ! [ Cmd.map AppMsg cmd ]

        ( TeamMsg subMsg, TeamManagement teamId subPage ) ->
            let
                ( newPage, cmd ) =
                    updateTeam subMsg subPage
            in
            TeamManagement teamId newPage ! [ Cmd.map TeamMsg cmd ]

        ( UserMsg subMsg, UserManagement subPage ) ->
            let
                ( newPage, cmd ) =
                    updateUser subMsg subPage user
            in
            UserManagement newPage ! [ Cmd.map UserMsg cmd ]

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            page ! []


updateDash : DashMessage -> DashboardPage -> ( DashboardPage, Cmd DashMessage )
updateDash msg page =
    case ( msg, page ) of
        ( DashboardMsg subMsg, Dashboard subModel ) ->
            let
                ( newPage, cmd ) =
                    Dashboard.update subMsg subModel
            in
            Dashboard newPage ! [ Cmd.map DashboardMsg cmd ]

        ( DownloadMsg subMsg, Download subModel ) ->
            let
                ( newPage, cmd ) =
                    Download.update subMsg subModel
            in
            Download newPage ! [ Cmd.map DownloadMsg cmd ]

        ( NewAppMsg subMsg, NewApp subModel ) ->
            let
                ( newPage, cmd ) =
                    NewApp.update subMsg subModel
            in
            NewApp newPage ! [ Cmd.map NewAppMsg cmd ]

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            page ! []


updateApp : AppMessage -> AppPage -> ( AppPage, Cmd AppMessage )
updateApp msg page =
    case ( msg, page ) of
        ( AppDashMsg subMsg, AppDash subModel ) ->
            let
                ( newPage, cmd ) =
                    AppDash.update subMsg subModel
            in
            AppDash newPage ! [ Cmd.map AppDashMsg cmd ]

        ( AppLogsMsg subMsg, AppLogs subModel ) ->
            let
                ( newPage, cmd ) =
                    AppLogs.update subMsg subModel
            in
            AppLogs newPage ! [ Cmd.map AppLogsMsg cmd ]

        ( AppHistoryMsg subMsg, AppHistory subModel ) ->
            let
                ( newPage, cmd ) =
                    AppHistory.update subMsg subModel
            in
            AppHistory newPage ! [ Cmd.map AppHistoryMsg cmd ]

        ( AppDnsMsg subMsg, AppDns subModel ) ->
            let
                ( newPage, cmd ) =
                    AppDns.update subMsg subModel
            in
            AppDns newPage ! [ Cmd.map AppDnsMsg cmd ]

        ( AppCertificatesMsg subMsg, AppCertificates subModel ) ->
            let
                ( newPage, cmd ) =
                    AppCertificates.update subMsg subModel
            in
            AppCertificates newPage ! [ Cmd.map AppCertificatesMsg cmd ]

        ( AppEvarsMsg subMsg, AppEvars subModel ) ->
            let
                ( newPage, cmd ) =
                    AppEvars.update subMsg subModel
            in
            AppEvars newPage ! [ Cmd.map AppEvarsMsg cmd ]

        ( AppBoxfileMsg subMsg, AppBoxfile subModel ) ->
            let
                ( newPage, cmd ) =
                    AppBoxfile.update subMsg subModel
            in
            AppBoxfile newPage ! [ Cmd.map AppBoxfileMsg cmd ]

        ( AppInfoMsg subMsg, AppInfo subModel ) ->
            let
                ( newPage, cmd ) =
                    AppInfo.update subMsg subModel
            in
            AppInfo newPage ! [ Cmd.map AppInfoMsg cmd ]

        ( AppOwnershipMsg subMsg, AppOwnership subModel ) ->
            let
                ( newPage, cmd ) =
                    AppOwnership.update subMsg subModel
            in
            AppOwnership newPage ! [ Cmd.map AppOwnershipMsg cmd ]

        ( AppDeployMsg subMsg, AppDeploy subModel ) ->
            let
                ( newPage, cmd ) =
                    AppDeploy.update subMsg subModel
            in
            AppDeploy newPage ! [ Cmd.map AppDeployMsg cmd ]

        ( AppUpdateMsg subMsg, AppUpdate subModel ) ->
            let
                ( newPage, cmd ) =
                    AppUpdate.update subMsg subModel
            in
            AppUpdate newPage ! [ Cmd.map AppUpdateMsg cmd ]

        ( AppSecurityMsg subMsg, AppSecurity subModel ) ->
            let
                ( newPage, cmd ) =
                    AppSecurity.update subMsg subModel
            in
            AppSecurity newPage ! [ Cmd.map AppSecurityMsg cmd ]

        ( AppDeleteMsg subMsg, AppDelete subModel ) ->
            let
                ( newPage, cmd ) =
                    AppDelete.update subMsg subModel
            in
            AppDelete newPage ! [ Cmd.map AppDeleteMsg cmd ]

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            page ! []


updateTeam : TeamMessage -> TeamPage -> ( TeamPage, Cmd TeamMessage )
updateTeam msg page =
    case ( msg, page ) of
        ( TeamInfoMsg subMsg, TeamInfo subModel ) ->
            let
                ( newPage, cmd ) =
                    TeamInfo.update subMsg subModel
            in
            TeamInfo newPage ! [ Cmd.map TeamInfoMsg cmd ]

        ( TeamSupportMsg subMsg, TeamSupport subModel ) ->
            let
                ( newPage, cmd ) =
                    TeamSupport.update subMsg subModel
            in
            TeamSupport newPage ! [ Cmd.map TeamSupportMsg cmd ]

        ( TeamBillingMsg subMsg, TeamBilling subModel ) ->
            let
                ( newPage, cmd ) =
                    TeamBilling.update subMsg subModel
            in
            TeamBilling newPage ! [ Cmd.map TeamBillingMsg cmd ]

        ( TeamPlanMsg subMsg, TeamPlan subModel ) ->
            let
                ( newPage, cmd ) =
                    TeamPlan.update subMsg subModel
            in
            TeamPlan newPage ! [ Cmd.map TeamPlanMsg cmd ]

        ( TeamMembersMsg subMsg, TeamMembers subModel ) ->
            let
                ( newPage, cmd ) =
                    TeamMembers.update subMsg subModel
            in
            TeamMembers newPage ! [ Cmd.map TeamMembersMsg cmd ]

        ( TeamAppGroupsMsg subMsg, TeamAppGroups subModel ) ->
            let
                ( newPage, cmd ) =
                    TeamAppGroups.update subMsg subModel
            in
            TeamAppGroups newPage ! [ Cmd.map TeamAppGroupsMsg cmd ]

        ( TeamHostingMsg subMsg, TeamHosting subModel ) ->
            let
                ( newPage, cmd ) =
                    TeamHosting.update subMsg subModel
            in
            TeamHosting newPage ! [ Cmd.map TeamHostingMsg cmd ]

        ( TeamDeleteMsg subMsg, TeamDelete subModel ) ->
            let
                ( newPage, cmd ) =
                    TeamDelete.update subMsg subModel
            in
            TeamDelete newPage ! [ Cmd.map TeamDeleteMsg cmd ]

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            page ! []


updateUser : UserMessage -> UserPage -> User -> ( UserPage, Cmd UserMessage )
updateUser msg page user =
    case ( msg, page ) of
        ( UserInfoMsg subMsg, UserInfo subModel ) ->
            let
                ( newPage, cmd ) =
                    UserInfo.update subMsg subModel
            in
            UserInfo newPage ! [ Cmd.map UserInfoMsg cmd ]

        ( UserSupportMsg subMsg, UserSupport subModel ) ->
            let
                ( newPage, cmd ) =
                    UserSupport.update subMsg subModel
            in
            UserSupport newPage ! [ Cmd.map UserSupportMsg cmd ]

        ( UserBillingMsg subMsg, UserBilling subModel ) ->
            let
                ( newPage, cmd ) =
                    UserBilling.update subMsg subModel
            in
            UserBilling newPage ! [ Cmd.map UserBillingMsg cmd ]

        ( UserPlanMsg subMsg, UserPlan subModel ) ->
            let
                ( newPage, cmd ) =
                    UserPlan.update subMsg subModel
            in
            UserPlan newPage ! [ Cmd.map UserPlanMsg cmd ]

        ( UserHostingMsg subMsg, UserHosting subModel ) ->
            let
                ( newPage, cmd ) =
                    UserHosting.update subMsg subModel user.authToken
            in
            UserHosting newPage ! [ Cmd.map UserHostingMsg cmd ]

        ( UserTeamsMsg subMsg, UserTeams subModel ) ->
            let
                ( newPage, cmd ) =
                    UserTeams.update subMsg subModel
            in
            UserTeams newPage ! [ Cmd.map UserTeamsMsg cmd ]

        ( UserDeleteMsg subMsg, UserDelete subModel ) ->
            let
                ( newPage, cmd ) =
                    UserDelete.update subMsg subModel
            in
            UserDelete newPage ! [ Cmd.map UserDeleteMsg cmd ]

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            page ! []



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        Unauthed unAuthedPage ->
            Sub.none

        Authed authedPage ->
            Sub.batch
                [ -- TODO: user-level subscription
                  Sub.map AuthedMsg <| authedSubscriptions authedPage
                ]


authedSubscriptions : AuthedPage -> Sub AuthedMessage
authedSubscriptions page =
    case page of
        AppManagement appId page ->
            -- TODO: app-level subscription
            Sub.map AppMsg <| appSubscriptions page

        UserManagement page ->
            Sub.map UserMsg <| userSubscriptions page

        _ ->
            Sub.none


appSubscriptions : AppPage -> Sub AppMessage
appSubscriptions page =
    case page of
        AppDash model ->
            Sub.map AppDashMsg <| AppDash.subscriptions model

        _ ->
            Sub.none


userSubscriptions : UserPage -> Sub UserMessage
userSubscriptions page =
    case page of
        UserHosting model ->
            Sub.map UserHostingMsg <| UserHosting.subscriptions model

        _ ->
            Sub.none



---- VIEW ----


view : Model -> Html Msg
view model =
    case model.page of
        Unauthed page ->
            div [ class "unauthed-page" ]
                [ Html.map UnauthedMsg <| viewUnauthedPage page
                ]

        Authed page ->
            div [ class "authed-page" ]
                [ TopNav.view model.flags AccountMenu.view
                , Html.map AuthedMsg <|
                    viewAuthedPage page model.activeRoute model.app <|
                        Maybe.withDefault User.initialModel model.user
                ]


viewUnauthedPage : UnauthedPage -> Html UnauthedMessage
viewUnauthedPage page =
    case page of
        NotFound ->
            NotFound.view

        Login submodel ->
            Html.map LoginMsg <|
                Login.view submodel

        Register submodel ->
            Html.map RegisterMsg <|
                Register.view submodel

        ForgotPassword submodel ->
            Html.map ForgotPasswordMsg <|
                ForgotPassword.view submodel


viewAuthedPage : AuthedPage -> Route -> Maybe App -> User -> Html AuthedMessage
viewAuthedPage page activeRoute app user =
    case page of
        DashPage page ->
            Html.map DashMsg <| viewDashboardPage page

        AppManagement appId page ->
            case app of
                Just app ->
                    let
                        ( _, activeRouteName ) =
                            Route.linkTo activeRoute
                    in
                    Corral.appAdmin activeRouteName appId <|
                        Html.map AppMsg <|
                            viewAppPage page app

                Nothing ->
                    -- TODO: Put loading page here
                    div [] [ text "Loading..." ]

        TeamManagement teamId page ->
            let
                ( _, activeRouteName ) =
                    Route.linkTo activeRoute
            in
            Corral.teamAdmin activeRouteName teamId <|
                Html.map TeamMsg <|
                    viewTeamPage page

        UserManagement page ->
            let
                ( _, activeRouteName ) =
                    Route.linkTo activeRoute
            in
            Corral.userAdmin activeRouteName <|
                Html.map UserMsg <|
                    viewUserPage page user


viewDashboardPage : DashboardPage -> Html DashMessage
viewDashboardPage page =
    case page of
        Dashboard submodel ->
            Html.map DashboardMsg <| Dashboard.view submodel

        Download submodel ->
            Html.map DownloadMsg <| Download.view submodel

        NewApp submodel ->
            Html.map NewAppMsg <| NewApp.view submodel


viewAppPage : AppPage -> App -> Html AppMessage
viewAppPage page app =
    case page of
        AppDash submodel ->
            Html.map AppDashMsg <| AppDash.view submodel app

        AppLogs submodel ->
            Html.map AppLogsMsg <| AppLogs.view submodel app

        AppHistory submodel ->
            Html.map AppHistoryMsg <| AppHistory.view submodel app

        AppDns submodel ->
            Html.map AppDnsMsg <| AppDns.view submodel app

        AppCertificates submodel ->
            Html.map AppCertificatesMsg <| AppCertificates.view submodel app

        AppEvars submodel ->
            Html.map AppEvarsMsg <| AppEvars.view submodel app

        AppBoxfile submodel ->
            Html.map AppBoxfileMsg <| AppBoxfile.view submodel app

        AppInfo submodel ->
            Html.map AppInfoMsg <| AppInfo.view submodel app

        AppOwnership submodel ->
            Html.map AppOwnershipMsg <| AppOwnership.view submodel app

        AppDeploy submodel ->
            Html.map AppDeployMsg <| AppDeploy.view submodel app

        AppUpdate submodel ->
            Html.map AppUpdateMsg <| AppUpdate.view submodel app

        AppSecurity submodel ->
            Html.map AppSecurityMsg <| AppSecurity.view submodel app

        AppDelete submodel ->
            Html.map AppDeleteMsg <| AppDelete.view submodel app


viewTeamPage : TeamPage -> Html TeamMessage
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


viewUserPage : UserPage -> User -> Html UserMessage
viewUserPage page user =
    case page of
        UserInfo submodel ->
            Html.map UserInfoMsg <| UserInfo.view submodel user

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



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Navigation.programWithFlags (Route.parseRoute >> RouteChange)
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
