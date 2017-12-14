module View.Material exposing (..)

import Html exposing (Attribute, Html, div, label, text)
import Html.Attributes exposing (class, required, type_)


input : List (Attribute msg) -> List (Html msg) -> Html msg
input inputAttributes labelInner =
    div [ class "material-input-box" ]
        [ Html.input
            ([ type_ "text", class "material-input", required True ] ++ inputAttributes)
            []
        , label [ class "material-label" ] labelInner
        ]
