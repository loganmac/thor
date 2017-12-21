module View.Lexi exposing (..)

import Html exposing (Attribute, Html, button, div, input, label, text)
import Html.Attributes exposing (class, classList, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Svg exposing (path, svg)
import Svg.Attributes exposing (d, viewBox)
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


saveSection : Bool -> msg -> msg -> Html msg
saveSection shouldHide cancelAction saveAction =
    div
        [ classList
            [ "save-section" => True
            , "hidden" => shouldHide
            ]
        ]
        [ button [ class "basic-button cancel", onClick cancelAction ] [ text "Cancel" ]
        , button [ class "basic-button", onClick saveAction ] [ text "Save" ]
        ]


passwordDialog : Bool -> String -> msg -> msg -> (String -> msg) -> Html msg
passwordDialog showIf currentPassword cancelMsg confirmMsg changeMsg =
    div [ classList [ "dialog" => True, "hidden" => not showIf ] ]
        [ div [ class "backdrop", onClick cancelMsg ] []
        , div [ class "box" ]
            [ closeX cancelMsg
            , div [ class "content" ]
                [ div [ class "message" ] [ text "Type your password to confirm:" ]
                , label [ class "basic-label" ] [ text "Password" ]
                , input
                    [ class "basic-input"
                    , type_ "password"
                    , placeholder "Password"
                    , value currentPassword
                    , onInput changeMsg
                    ]
                    []
                , div [ class "confirm-section" ]
                    [ button [ class "basic-button cancel", onClick cancelMsg ] [ text "Cancel" ]
                    , button [ class "basic-button danger", onClick confirmMsg ] [ text "Confirm" ]
                    ]
                ]
            ]
        ]


closeX : msg -> Html msg
closeX cancelMsg =
    div [ class "close-box", onClick cancelMsg ]
        [ svg [ viewBox "0 0 40 40" ]
            [ path [ Svg.Attributes.class "close-x", d "M 10,10 L 30,30 M 30,10 L 10,30" ]
                []
            ]
        ]
