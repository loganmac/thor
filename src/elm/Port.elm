port module Port exposing (..)

import Json.Encode exposing (Value)


{-| measureContent the change animation of a flexWrapper
-}
port measureContent :
    { containerId : String
    , contentId : String
    , oldContentId : String
    , parentId : String
    }
    -> Cmd msg


{-| sends back the height of the new content.
-}
port newContentHeight :
    ({ containerId : String
     , contentId : String
     , newHeight : Float
     , oldHeight : Float
     , parentId : String
     }
     -> msg
    )
    -> Sub msg


{-| sends a session out to be stored in localStorage
-}
port storeSession : Maybe String -> Cmd msg


{-| get a message that localStorage.session has changed
-}
port onSessionChange : (Value -> msg) -> Sub msg
