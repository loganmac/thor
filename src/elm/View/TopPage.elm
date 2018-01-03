module View.TopPage exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (class)


view : Html msg -> Html msg
view inner =
    div [ class "top-page" ] [ inner ]
