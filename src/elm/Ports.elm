port module Ports exposing (..)


port toJs : String -> Cmd msg


{-| Requests a new uuid v4 from javascript
-}
port generateUuid : () -> Cmd msg


{-| receives a new uuid v4 from javascript
-}
port uuid : (String -> msg) -> Sub msg
