module Page.User.Hosting exposing (..)

-- TODO: not implemented.

import Data.AuthToken exposing (AuthToken)
import Data.Hosting as Hosting
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Http
import Port


-- MODEL


type alias Model =
    {}


type alias AccountRequest =
    { requestId : String
    , accountId : String
    , providerId : String
    }


type alias RequestId =
    String


type alias ProviderId =
    String


init : ( Model, Cmd Msg )
init =
    {} ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Port.deleteAccount DeleteAccount



-- UPDATE


type Msg
    = DeleteAccount AccountRequest
    | DeleteAccountResponse RequestId ProviderId (Result Http.Error ())
    | DeleteProviderResponse RequestId (Result Http.Error ())


update : Msg -> Model -> AuthToken -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        DeleteAccount { requestId, accountId, providerId } ->
            model
                ! [ Http.send (DeleteAccountResponse requestId providerId) <|
                        Hosting.deleteAccount accountId (Just token)
                  ]

        DeleteAccountResponse requestId providerId (Ok ()) ->
            model
                ! [ Http.send (DeleteProviderResponse providerId) <|
                        Hosting.deleteProvider providerId (Just token)
                  ]

        DeleteAccountResponse requestId _ (Err err) ->
            model
                ! [ Port.accountDeleted
                        { requestId = requestId
                        , success = False
                        , error = Just <| toString err
                        }
                  ]

        DeleteProviderResponse requestId (Ok ()) ->
            model
                ! [ Port.accountDeleted
                        { requestId = requestId
                        , success = True
                        , error = Nothing
                        }
                  ]

        DeleteProviderResponse requestId (Err err) ->
            model
                ! [ Port.accountDeleted
                        { requestId = requestId
                        , success = False
                        , error = Just <| toString err
                        }
                  ]



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "user-hosting" ] []
