module Page.NotFound exposing (..)

-- TODO: not implemented.

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Util exposing ((=>))


-- VIEW


view : msg -> Html msg
view msg =
    div [ class "not-found" ] [ text "Not Found not yet implemented" ]
