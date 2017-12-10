port module Ports exposing (..)

{-| animates the change animation of a flexWrapper
send a tabContainerId, and a tabId
-}


port animateChangeTab : ( String, String ) -> Cmd msg


{-| sends back the new height of a tab.
sends back a tabContainerId, tabId, and a height
-}
port newTabHeight : (( String, String, String ) -> msg) -> Sub msg
