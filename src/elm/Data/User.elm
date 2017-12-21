module Data.User exposing (..)

import Data.Helpers exposing (apiUrl)
import Http
import Json.Decode as Decode exposing (Decoder, nullable)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)


-- MODEL


type alias User =
    { id : String
    , username : String
    , email : String
    , authToken : String
    }


initialModel : User
initialModel =
    { id = ""
    , username = ""
    , email = ""
    , authToken = ""
    }


decoder : Decoder User
decoder =
    decode User
        |> required "id" Decode.string
        |> required "username" Decode.string
        |> required "email" Decode.string
        |> required "auth_token" Decode.string



-- REQUESTS
-- GET


getUser : String -> (Result Http.Error User -> msg) -> Cmd msg
getUser userId msg =
    Http.send msg <| Http.get (apiUrl <| "users/" ++ userId) decoder
