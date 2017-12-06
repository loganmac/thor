module Lexi.Styled.Label exposing (..)

import Css exposing (..)
import Html
import Html.Styled exposing (Attribute, Html, div, fromUnstyled, label, styled, text, toUnstyled)
import Html.Styled.Attributes exposing (css)
import Lexi.Styled.Base exposing (colors, fontWeights)


labelStyle : Style
labelStyle =
    Css.batch
        [ display inlineBlock
        , position relative
        , fontSize (px 16)
        , fontWeight (int fontWeights.semiBold)
        , fontStyle italic
        , paddingLeft (px 6)
        , before
            [ paddingLeft (px 0)
            , paddingRight (px 6)
            ]

        -- , padding (px 0) -- TODO: Ask Mark about this one?
        , whiteSpace noWrap
        ]


lightLabelStyle : Style
lightLabelStyle =
    Css.batch
        [ labelStyle
        , color colors.azul2
        ]


darkLabelStyle : Style
darkLabelStyle =
    Css.batch
        [ labelStyle
        , color colors.azul2Darker
        ]


lightLabel : List (Html.Html msg) -> Html.Html msg
lightLabel inner =
    toUnstyled <|
        label [ css [ lightLabelStyle ] ] (List.map fromUnstyled inner)


darkLabel : List (Html.Html msg) -> Html.Html msg
darkLabel inner =
    toUnstyled <|
        label [ css [ darkLabelStyle ] ] (List.map fromUnstyled inner)
