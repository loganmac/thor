module Data.User exposing (..)

import Data.AuthToken as AuthToken exposing (AuthToken(..))
import Data.Helpers exposing (apiPost, apiUrl)
import Http
import Json.Decode as Decode exposing (Decoder, Value, nullable)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode as Encode
import Port
import Util exposing ((=>))


-- MODEL


type alias User =
    { id : Id
    , username : String
    , email : String
    , authToken : AuthToken
    }


type Id
    = Id String


encodeId : Id -> Value
encodeId (Id id) =
    Encode.string id


decodeId : Decoder Id
decodeId =
    Decode.map Id Decode.string


initialModel : User
initialModel =
    { id = Id ""
    , username = ""
    , email = ""
    , authToken = AuthToken ""
    }


decoder : Decoder User
decoder =
    decode User
        |> required "id" (Decode.map Id Decode.string)
        |> required "username" Decode.string
        |> required "email" Decode.string
        |> required "auth_token" AuthToken.decoder


encode : User -> Value
encode user =
    Encode.object
        [ "id" => encodeId user.id
        , "username" => Encode.string user.username
        , "email" => Encode.string user.email
        , "auth_token" => AuthToken.encode user.authToken
        ]



-- SESSION


attempt : String -> (AuthToken -> Cmd msg) -> Maybe User -> ( List String, Cmd msg )
attempt attemptedAction toCmd user =
    case Maybe.map .authToken user of
        Nothing ->
            [ "You have been signed out. Please sign back in to " ++ attemptedAction ++ "." ] => Cmd.none

        Just token ->
            [] => toCmd token


fromSession : Value -> Maybe User
fromSession json =
    json
        |> Decode.decodeValue Decode.string
        |> Result.toMaybe
        |> Maybe.andThen (Decode.decodeString decoder >> Result.toMaybe)


storeSession : User -> Cmd msg
storeSession user =
    Port.storeSession <| Just <| Encode.encode 0 <| encode user



-- REQUESTS
-- LOGIN
-- TODO: might not be necessary?


login : { r | username : String, password : String } -> Http.Request User
login { username, password } =
    let
        user =
            Encode.object
                [ "slug" => Encode.string username
                , "password" => Encode.string password
                ]

        body =
            Http.jsonBody <| user

        url =
            apiUrl "user/auth"
    in
    Http.post url body decoder


decodeLoginErrors : String -> List String
decodeLoginErrors str =
    Result.withDefault [] <|
        Decode.decodeString
            (Decode.field "errors" <|
                optionalError "password" <|
                    optionalError "username" <|
                        decode (\username password -> List.concat [ username, password ])
            )
            str


optionalError : String -> Decoder (List String -> a) -> Decoder a
optionalError fieldName =
    let
        errorToString errorMessage =
            String.join " " [ fieldName, errorMessage ]
    in
    Pipeline.optional fieldName (Decode.list (Decode.map errorToString Decode.string)) []



-- GET


getUser : String -> (Result Http.Error User -> msg) -> Cmd msg
getUser userId msg =
    Http.send msg <| Http.get (apiUrl <| "users/" ++ userId) decoder



-- POST
