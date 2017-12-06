module Lexi.Simple.Checkbox exposing (..)

import Html exposing (Attribute, Html, div, input, label, text)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick)


type LabelPosition
    = LabelBefore
    | LabelAfter


type alias Config msg =
    { msg : msg
    , isChecked : Bool
    , labelPosition : LabelPosition
    , text : String
    }


checkbox : Config msg -> Html.Html msg
checkbox config =
    let
        box inner =
            div
                [ checkedClass config.isChecked "lexi-ui checkbox"
                , onClick config.msg
                ]
                inner

        checker =
            div [ class "checker" ] []

        checklabel =
            label [ class "label" ] [ text config.text ]
    in
    case config.labelPosition of
        LabelBefore ->
            box [ checklabel, checker ]

        LabelAfter ->
            box [ checker, checklabel ]


checkedClass : Bool -> String -> Attribute msg
checkedClass isChecked baseClass =
    if isChecked then
        class (baseClass ++ " checked")
    else
        class baseClass
