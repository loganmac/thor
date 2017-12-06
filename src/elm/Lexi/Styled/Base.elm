module Lexi.Styled.Base exposing (..)

import Css exposing (..)


colors :
    { azul : Color
    , azul2 : Color
    , azul2Blue : Color
    , azul2Darker : Color
    , white : Color
    }
colors =
    -- bright blues
    { azul = hex "1EB8FF"
    , azul2 = hex "00A2ED"

    -- blue background theme
    , azul2Blue = hex "1D8ACD"
    , azul2Darker = hex "186999"
    , white = hex "FFFFFF"
    }


fontWeights : { semiBold : Int }
fontWeights =
    { semiBold = 600 }
