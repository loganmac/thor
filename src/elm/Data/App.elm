module Data.App exposing (..)

import Data.Helpers exposing (apiUrl)
import Http
import Json.Decode as Decode exposing (Decoder, nullable)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)


-- MODEL


type alias App =
    { id : String
    , name : String
    , timezone : String
    , state : String
    , autoReconfigure : Bool
    , config : Maybe String
    , providerId : String
    , providerName : String
    , providerIcon : String
    , providerEndpoint : Maybe String
    , platformId : String
    , platformRegion : String
    , groupId : String
    , groupName : String
    }


initialModel : App
initialModel =
    { id = ""
    , name = ""
    , timezone = ""
    , state = ""
    , autoReconfigure = False
    , config = Just ""
    , providerId = ""
    , providerName = ""
    , providerIcon = ""
    , providerEndpoint = Just ""
    , platformId = ""
    , platformRegion = ""
    , groupId = ""
    , groupName = ""
    }


decoder : Decoder App
decoder =
    decode App
        |> required "id" Decode.string
        |> required "name" Decode.string
        |> required "timezone" Decode.string
        |> required "state" Decode.string
        |> required "auto_reconfigure" Decode.bool
        |> required "config" (nullable Decode.string)
        |> required "provider_id" Decode.string
        |> required "provider_name" Decode.string
        |> required "provider_icon" Decode.string
        |> required "provider_endpoint" (nullable Decode.string)
        |> required "platform_id" Decode.string
        |> required "platform_region" Decode.string
        |> required "group_id" Decode.string
        |> required "group_name" Decode.string



-- REQUESTS
-- GET


appUrl : String -> String
appUrl appId =
    apiUrl <| "apps/" ++ appId


getApp : String -> (Result Http.Error App -> msg) -> Cmd msg
getApp appId msg =
    Http.send msg <| Http.get (appUrl appId) decoder
