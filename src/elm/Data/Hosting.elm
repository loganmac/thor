module Data.Hosting exposing (..)

import Data.AuthToken as AuthToken exposing (AuthToken)
import Data.Helpers exposing (apiUrl)
import Http
import HttpBuilder


deleteAccount : String -> Maybe AuthToken -> Http.Request ()
deleteAccount accountId token =
    apiUrl ("/provider_accounts/" ++ accountId)
        |> HttpBuilder.delete
        |> AuthToken.withAuthorization token
        |> HttpBuilder.toRequest


deleteProvider : String -> Maybe AuthToken -> Http.Request ()
deleteProvider providerId token =
    apiUrl ("/providers/" ++ providerId)
        |> HttpBuilder.delete
        |> AuthToken.withAuthorization token
        |> HttpBuilder.toRequest
