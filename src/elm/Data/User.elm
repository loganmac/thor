module Data.User exposing (..)

import Data.Helpers exposing (apiUrl)
import Http
import Json.Decode as Decode exposing (Decoder, nullable)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)


-- MODEL


type alias User =
    { id : Id
    , username : String
    , email : String
    , authToken : String
    }


type Id
    = Id String


initialModel : User
initialModel =
    { id = Id ""
    , username = ""
    , email = ""
    , authToken = ""
    }


decoder : Decoder User
decoder =
    decode User
        |> required "id" (Decode.map Id Decode.string)
        |> required "username" Decode.string
        |> required "email" Decode.string
        |> required "auth_token" Decode.string



-- REQUESTS
-- GET


getUser : String -> (Result Http.Error User -> msg) -> Cmd msg
getUser userId msg =
    Http.send msg <| Http.get (apiUrl <| "users/" ++ userId) decoder
