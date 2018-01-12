module Data.App exposing (..)

import Data.AuthToken as AuthToken
import Data.Helpers exposing (apiUrl)
import Http
import HttpBuilder
import Json.Decode as Decode exposing (Decoder, nullable)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import UrlParser


-- MODEL


type alias App =
    { id : Id
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
    { id = Id ""
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


type Id
    = Id String


idParser : UrlParser.Parser (Id -> a) a
idParser =
    UrlParser.custom "ID" <| Ok << Id


decoder : Decoder App
decoder =
    decode App
        |> required "id" (Decode.map Id Decode.string)
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


getApp : String -> Maybe AuthToken.AuthToken -> (Result Http.Error App -> msg) -> Cmd msg
getApp appId authToken msg =
    appUrl appId
        |> HttpBuilder.get
        |> AuthToken.withAuthorization authToken
        |> HttpBuilder.withExpect (Http.expectJson decoder)
        |> HttpBuilder.toRequest
        |> Http.send msg



-- POST


newAppUrl : String
newAppUrl =
    apiUrl "apps"


validateUrl : String
validateUrl =
    apiUrl "apps/validate_name"
