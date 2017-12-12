module View.TopNav exposing (..)

import Html exposing (Attribute, Html, div, img, text)
import Html.Attributes exposing (alt, class, src)


-- VIEW


view : String -> Html msg -> Html msg
view logoPath inner =
    div [ class "top-nav" ]
        [ div [ class "logo" ]
            [ img [ src logoPath ] []
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
        , inner
        ]
