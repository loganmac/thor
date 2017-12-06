module Lexi.Styled.Checkbox exposing (..)

import Css exposing (..)
import Html
import Html.Styled exposing (Attribute, Html, div, fromUnstyled, input, text, toUnstyled)
import Html.Styled.Attributes exposing (css, type_)
import Html.Styled.Events exposing (onClick)
import Lexi.Styled.Base exposing (colors)


type Theme
    = Light
    | Dark


type LabelPosition
    = LabelBefore
    | LabelAfter


type alias Config msg =
    { msg : msg
    , isChecked : Bool
    , labelPosition : LabelPosition
    , label : Html.Html msg
    , theme : Theme
    }


{-| lightCheckbox builds a themed checkbox. Needs a `Config`
-}
checkbox : Config msg -> Html.Html msg
checkbox config =
    let
        box inner =
            div [ onClick config.msg, css [ checkboxStyle ] ]
                inner

        checkLabel =
            fromUnstyled config.label

        checker =
            div [ css [ activeStyle config.isChecked, themeColor config.theme ] ] []
    in
    toUnstyled <|
        case config.labelPosition of
            LabelBefore ->
                box [ checkLabel, checker ]

            LabelAfter ->
                box [ checker, checkLabel ]


checkboxStyle : Style
checkboxStyle =
    Css.batch
        [ display inlineFlex
        , cursor pointer
        , alignItems center
        ]


checkerStyle : Style
checkerStyle =
    Css.batch
        [ position relative
        , width (px 16)
        , height (px 16)
        , backgroundColor colors.azul2
        , display inlineBlock
        , borderRadius (px 2)
        ]


checkerCheckedStyle : Style
checkerCheckedStyle =
    Css.batch
        [ checkerStyle
        , after
            [ checkMark 14 colors.white 3
            , boxSizing borderBox
            , position absolute
            , left (px 7)
            , top (px -2)
            ]
        ]


checkMark : Float -> Color -> Float -> Style
checkMark checkSize checkColor lineWidth =
    Css.batch
        -- Add another block-level blank space
        [ property "content" "close-quote"
        , display block

        -- Make it a small rectangle so the border will create an L-shape
        , width (px (checkSize / 2))
        , height (px checkSize)

        -- Add a white border on the bottom and left, creating that 'L'
        , borderStyle solid
        , borderColor checkColor
        , borderWidth4 (px 0) (px lineWidth) (px lineWidth) (px 0)

        -- Rotate the L 45 degrees to turn it into a checkmark
        , transform (rotate (deg 45))
        ]


activeStyle : Bool -> Style
activeStyle isChecked =
    if isChecked then
        checkerCheckedStyle
    else
        checkerStyle


themeColor : Theme -> Style
themeColor contrast =
    case contrast of
        Light ->
            backgroundColor colors.azul2

        Dark ->
            backgroundColor colors.azul2Blue
