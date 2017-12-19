module View.Lexi exposing (..)

import Html exposing (Attribute, Html, div, input, label, text)
import Html.Attributes exposing (class, classList, type_)
import Html.Events exposing (onClick)
import Util exposing ((=>))


checkbox : msg -> Bool -> List (Html msg) -> Html msg
checkbox msg isChecked inner =
    div
        [ classList
            [ "checkbox" => True
            , "checked" => isChecked
            ]
        , onClick msg
        ]
        [ div [ class "checker" ] []
        , label [ class "label" ] inner
        ]
