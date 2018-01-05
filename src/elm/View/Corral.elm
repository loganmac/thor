module View.Corral exposing (..)

import Html exposing (Attribute, Html, a, div, text)
import Html.Attributes exposing (class, classList)
import Util exposing ((=>))


-- MODEL


type alias ActiveRoute =
    String


type alias Title =
    String


type alias Text =
    String



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
