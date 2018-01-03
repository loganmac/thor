module Route exposing (..)

import Data.App as App
import Data.Team as Team
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>))


type Route
    = -- Top level
      NotFound
    | Login
    | Register
    | ForgotPassword
      -- Authenticated/dashboard routes
    | Dashboard
    | Download
    | NewApp
      -- App management
    | AppDash App.Id
    | AppLogs App.Id
    | AppHistory App.Id
    | AppDns App.Id
    | AppCertificates App.Id
    | AppEvars App.Id
    | AppBoxfile App.Id
    | AppInfo App.Id
    | AppOwnership App.Id
    | AppDeploy App.Id
    | AppUpdate App.Id
    | AppSecurity App.Id
    | AppDelete App.Id
      -- Team management
    | TeamInfo Team.Id
    | TeamSupport Team.Id
    | TeamBilling Team.Id
    | TeamPlan Team.Id
    | TeamMembers Team.Id
    | TeamAppGroups Team.Id
    | TeamHosting Team.Id
    | TeamDelete Team.Id
      -- Account management
    | UserInfo
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
        [ Url.map NotFound (Url.s "not-found")
        , Url.map Login (Url.s "login")
        , Url.map Register (Url.s "register")
        , Url.map ForgotPassword (Url.s "forgot-password")
        , Url.map Dashboard Url.top
        , Url.map Dashboard (Url.s "apps")
        , Url.map Download (Url.s "download")
        , Url.map NewApp (Url.s "apps" </> Url.s "new")

        -- App management
        , Url.map AppDash (Url.s "apps" </> App.idParser)
        , Url.map AppLogs (Url.s "apps" </> App.idParser </> Url.s "logs")
        , Url.map AppHistory (Url.s "apps" </> App.idParser </> Url.s "history")
        , Url.map AppDns (Url.s "apps" </> App.idParser </> Url.s "dns")
        , Url.map AppCertificates (Url.s "apps" </> App.idParser </> Url.s "certificates")
        , Url.map AppEvars (Url.s "apps" </> App.idParser </> Url.s "evars")
        , Url.map AppBoxfile (Url.s "apps" </> App.idParser </> Url.s "boxfile")
        , Url.map AppInfo (Url.s "apps" </> App.idParser </> Url.s "info")
        , Url.map AppOwnership (Url.s "apps" </> App.idParser </> Url.s "ownership")
        , Url.map AppDeploy (Url.s "apps" </> App.idParser </> Url.s "deploy")
        , Url.map AppUpdate (Url.s "apps" </> App.idParser </> Url.s "update")
        , Url.map AppSecurity (Url.s "apps" </> App.idParser </> Url.s "security")
        , Url.map AppDelete (Url.s "apps" </> App.idParser </> Url.s "delete")

        -- Team management
        , Url.map TeamInfo (Url.s "teams" </> Team.idParser </> Url.s "admin")
        , Url.map TeamSupport (Url.s "teams" </> Team.idParser </> Url.s "support")
        , Url.map TeamBilling (Url.s "teams" </> Team.idParser </> Url.s "billing")
        , Url.map TeamPlan (Url.s "teams" </> Team.idParser </> Url.s "plan")
        , Url.map TeamMembers (Url.s "teams" </> Team.idParser </> Url.s "members")
        , Url.map TeamAppGroups (Url.s "teams" </> Team.idParser </> Url.s "app-groups")
        , Url.map TeamHosting (Url.s "teams" </> Team.idParser </> Url.s "hosting")
        , Url.map TeamDelete (Url.s "teams" </> Team.idParser </> Url.s "delete")

        -- User management
        , Url.map UserInfo (Url.s "user" </> Url.s "info")
        , Url.map UserSupport (Url.s "user" </> Url.s "support")
        , Url.map UserBilling (Url.s "user" </> Url.s "billing")
        , Url.map UserPlan (Url.s "user" </> Url.s "plan")
        , Url.map UserHosting (Url.s "user" </> Url.s "hosting")
        , Url.map UserTeams (Url.s "user" </> Url.s "teams")
        , Url.map UserDelete (Url.s "user" </> Url.s "delete")
        ]


parseRoute : Location -> Route
parseRoute location =
    if String.isEmpty location.hash then
        Dashboard
    else
        case Url.parseHash routes location of
            Just route ->
                route

            Nothing ->
                NotFound
