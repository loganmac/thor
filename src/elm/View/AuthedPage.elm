module View.AuthedPage exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import View.AccountMenu as AccountMenu
import View.TopNav as TopNav


view : TopNav.LogoPaths r -> Html msg -> Html msg
view logos inner =
    div [ class "authed-page" ]
        [ TopNav.view logos AccountMenu.view
        , inner
        ]
