module Page.AppAdmin exposing (..)

import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class)
import Page.Core.Corral as Corral


-- VIEW


view : (String -> msg) -> Corral.Model -> Html msg
view corralItemClicked model =
    div [ class "app-admin" ]
        [ Corral.view model corralItemClicked (text "")
        ]


navItem : String -> Html msg
navItem txt =
    div [ class "item" ]
        [ text txt
        ]
