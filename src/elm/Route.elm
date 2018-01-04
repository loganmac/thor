module Route exposing (..)

import Data.App as App
import Data.Team as Team
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>))


type Route
    = Unauthed UnauthedRoute
    | Authed AuthedRoute


type UnauthedRoute
    = NotFound
    | Login
    | Register
    | ForgotPassword


type AuthedRoute
    = Dash DashboardRoute
    | App App.Id AppRoute
    | Team Team.Id TeamRoute
    | User UserRoute


type DashboardRoute
    = Dashboard
    | Download
    | NewApp


type AppRoute
    = AppDash
    | AppLogs
    | AppHistory
    | AppDns
    | AppCertificates
    | AppEvars
    | AppBoxfile
    | AppInfo
    | AppOwnership
    | AppDeploy
    | AppUpdate
    | AppSecurity
    | AppDelete


type TeamRoute
    = TeamInfo
    | TeamSupport
    | TeamBilling
    | TeamPlan
    | TeamMembers
    | TeamAppGroups
    | TeamHosting
    | TeamDelete


type UserRoute
    = UserInfo
    | UserSupport
    | UserBilling
    | UserPlan
    | UserHosting
    | UserTeams
    | UserDelete


routes : Url.Parser (Route -> a) a
routes =
    Url.oneOf
        -- Top level routes
        [ Url.map Unauthed <| unauthedRoutes
        , Url.map Authed <| authedRoutes
        ]


unauthedRoutes : Url.Parser (UnauthedRoute -> a) a
unauthedRoutes =
    Url.oneOf
        [ Url.map NotFound <| Url.s "not-found"
        , Url.map Login <| Url.s "login"
        , Url.map Register <| Url.s "register"
        , Url.map ForgotPassword <| Url.s "forgot-password"
        ]


authedRoutes : Url.Parser (AuthedRoute -> a) a
authedRoutes =
    Url.oneOf
        [ Url.map Dash <| dashRoutes
        , Url.map App <| Url.s "apps" </> App.idParser </> appRoutes
        , Url.map Team <| Url.s "teams" </> Team.idParser </> teamRoutes
        , Url.map User <| Url.s "user" </> userRoutes
        ]


dashRoutes : Url.Parser (DashboardRoute -> a) a
dashRoutes =
    Url.oneOf
        [ Url.map Dashboard <| Url.top
        , Url.map Dashboard <| Url.s "apps"
        , Url.map Download <| Url.s "download"
        , Url.map NewApp <| Url.s "apps" </> Url.s "new"
        ]


appRoutes : Url.Parser (AppRoute -> a) a
appRoutes =
    Url.oneOf
        [ Url.map AppDash <| Url.top
        , Url.map AppLogs <| Url.s "logs"
        , Url.map AppHistory <| Url.s "history"
        , Url.map AppDns <| Url.s "dns"
        , Url.map AppCertificates <| Url.s "certificates"
        , Url.map AppEvars <| Url.s "evars"
        , Url.map AppBoxfile <| Url.s "boxfile"
        , Url.map AppInfo <| Url.s "info"
        , Url.map AppOwnership <| Url.s "ownership"
        , Url.map AppDeploy <| Url.s "deploy"
        , Url.map AppUpdate <| Url.s "update"
        , Url.map AppSecurity <| Url.s "security"
        , Url.map AppDelete <| Url.s "delete"
        ]


teamRoutes : Url.Parser (TeamRoute -> a) a
teamRoutes =
    Url.oneOf
        [ Url.map TeamInfo <| Url.s "admin"
        , Url.map TeamSupport <| Url.s "support"
        , Url.map TeamBilling <| Url.s "billing"
        , Url.map TeamPlan <| Url.s "plan"
        , Url.map TeamMembers <| Url.s "members"
        , Url.map TeamAppGroups <| Url.s "app-groups"
        , Url.map TeamHosting <| Url.s "hosting"
        , Url.map TeamDelete <| Url.s "delete"
        ]


userRoutes : Url.Parser (UserRoute -> a) a
userRoutes =
    Url.oneOf
        [ Url.map UserInfo <| Url.s "info"
        , Url.map UserSupport <| Url.s "support"
        , Url.map UserPlan <| Url.s "plan"
        , Url.map UserHosting <| Url.s "hosting"
        , Url.map UserTeams <| Url.s "teams"
        , Url.map UserDelete <| Url.s "delete"
        ]


parseRoute : Location -> Route
parseRoute location =
    if String.isEmpty location.hash then
        Authed <| Dash <| Dashboard
    else
        case Url.parseHash routes location of
            Just route ->
                route

            Nothing ->
                Unauthed <| NotFound
