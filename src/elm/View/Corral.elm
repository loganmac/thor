module View.Corral exposing (..)

import Data.App
import Data.Team
import Html exposing (Attribute, Html, a, div, text)
import Html.Attributes exposing (class, classList)
import Route
import Util exposing ((=>))


-- MODEL


type alias ActiveRoute =
    String


type alias Title =
    String


type alias Text =
    String


appAdmin : ActiveRoute -> Data.App.Id -> Html msg -> Html msg
appAdmin activeRouteName appId inner =
    view "Manage App"
        activeRouteName
        [ Route.linkTo (Route.Authed <| Route.App appId <| Route.AppInfo)
        , Route.linkTo (Route.Authed <| Route.App appId <| Route.AppOwnership)
        , Route.linkTo (Route.Authed <| Route.App appId <| Route.AppDeploy)
        , Route.linkTo (Route.Authed <| Route.App appId <| Route.AppUpdate)
        , Route.linkTo (Route.Authed <| Route.App appId <| Route.AppSecurity)
        , Route.linkTo (Route.Authed <| Route.App appId <| Route.AppDelete)
        ]
        inner


teamAdmin : ActiveRoute -> Data.Team.Id -> Html msg -> Html msg
teamAdmin activeRouteName teamId inner =
    view "Team Admin"
        activeRouteName
        [ Route.linkTo (Route.Authed <| Route.Team teamId <| Route.TeamInfo)
        , Route.linkTo (Route.Authed <| Route.Team teamId <| Route.TeamSupport)
        , Route.linkTo (Route.Authed <| Route.Team teamId <| Route.TeamBilling)
        , Route.linkTo (Route.Authed <| Route.Team teamId <| Route.TeamPlan)
        , Route.linkTo (Route.Authed <| Route.Team teamId <| Route.TeamMembers)
        , Route.linkTo (Route.Authed <| Route.Team teamId <| Route.TeamAppGroups)
        , Route.linkTo (Route.Authed <| Route.Team teamId <| Route.TeamHosting)
        , Route.linkTo (Route.Authed <| Route.Team teamId <| Route.TeamDelete)
        ]
        inner


userAdmin : ActiveRoute -> Html msg -> Html msg
userAdmin activeRouteName inner =
    view "Account Admin"
        activeRouteName
        [ Route.linkTo (Route.Authed <| Route.User <| Route.UserInfo)
        , Route.linkTo (Route.Authed <| Route.User <| Route.UserSupport)
        , Route.linkTo (Route.Authed <| Route.User <| Route.UserBilling)
        , Route.linkTo (Route.Authed <| Route.User <| Route.UserPlan)
        , Route.linkTo (Route.Authed <| Route.User <| Route.UserHosting)
        , Route.linkTo (Route.Authed <| Route.User <| Route.UserTeams)
        , Route.linkTo (Route.Authed <| Route.User <| Route.UserDelete)
        ]
        inner



-- VIEW


view : Title -> ActiveRoute -> List ( Attribute msg, Text ) -> Html msg -> Html msg
view title activeRoute links inner =
    div [ class "corral" ]
        [ div [ class "nav" ]
            [ div [ class "section-title" ]
                [ text title ]
            , div [ class "nav-bar" ] <|
                List.map (viewNavItem activeRoute) links
            ]
        , div [ class "content" ]
            [ div [ class "section-title" ] [ text activeRoute ]
            , div [ class "content" ]
                [ div [ class "content-item" ] [ inner ]
                ]
            ]
        ]


viewNavItem : ActiveRoute -> ( Attribute msg, Text ) -> Html msg
viewNavItem activeRoute ( link, linkText ) =
    a
        [ classList
            [ "nav-item" => True
            , "active" => activeRoute == linkText
            ]
        , link
        ]
        [ text linkText ]
