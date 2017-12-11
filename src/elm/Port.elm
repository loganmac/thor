port module Port exposing (..)

{-| measureContent the change animation of a flexWrapper
-}


port measureContent : { containerId : String, contentId : String } -> Cmd msg


{-| sends back the height of the new content.
-}
port newContentHeight : ({ containerId : String, contentId : String, newHeight : Float } -> msg) -> Sub msg
