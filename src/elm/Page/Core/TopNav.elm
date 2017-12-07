module Page.Core.TopNav exposing (..)

import Html exposing (Attribute, Html, div, img, text)
import Html.Attributes exposing (alt, class, src)
import Page.Core.AccountMenu as AccountMenu


-- VIEW


view : Html msg
view =
    div [ class "top-nav" ]
        [ div [ class "logo" ]
            [ img [ src "src/svg/logo.svg" ] []
            , div [ class "txt caps" ] [ text "Nanobox" ]
            ]
        , div [ class "link caps" ]
            [ img [ src "src/svg/home.svg" ] []
            , div [ class "txt" ] [ text "Home" ]
            ]
        , div [ class "link caps" ]
            [ img [ src "src/svg/support.svg" ] []
            , div [ class "txt" ] [ text "Support" ]
            ]
        , AccountMenu.view
        ]
