module Page.Auth.Login exposing (..)

-- TODO: not styled, just roughed in to test auth.

import Data.User as User exposing (User)
import Html exposing (Html, button, div, form, input, label, text)
import Html.Attributes exposing (class, classList, placeholder, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import Util exposing ((=>))
import Validate


-- MODEL


type alias Model =
    { errors : List String
    , username : String
    , password : String
    }


init : Model
init =
    { errors = []
    , username = ""
    , password = ""
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


type Msg
    = SubmitForm
    | SetUsername String
    | SetPassword String
    | LoginCompleted (Result Http.Error User)


update : Msg -> Model -> ( Model, Cmd Msg, Maybe User )
update msg model =
    case msg of
        SubmitForm ->
            case validate model of
                [] ->
                    ( { model | errors = [] }
                    , Http.send LoginCompleted (User.login model)
                    , Nothing
                    )

                errors ->
                    ( { model | errors = errors }, Cmd.none, Nothing )

        SetUsername username ->
            ( { model | username = username }, Cmd.none, Nothing )

        SetPassword password ->
            ( { model | password = password }, Cmd.none, Nothing )

        LoginCompleted (Ok user) ->
            ( model, Cmd.none, Just user )

        LoginCompleted (Err error) ->
            let
                errorMessages =
                    case error of
                        Http.BadStatus response ->
                            User.decodeLoginErrors response.body

                        _ ->
                            [ "Unable to login. Please try again later." ]
            in
            ( { model | errors = errorMessages }, Cmd.none, Nothing )


validate : Model -> List String
validate =
    Validate.all
        [ .username >> Validate.ifBlank "Username can't be blank."
        , .password >> Validate.ifBlank "Password can't be blank."
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "login" ]
        [ div
            [ classList
                [ "errors" => True
                , "hidden" => List.isEmpty model.errors
                ]
            ]
          <|
            List.map viewError model.errors
        , form [ onSubmit SubmitForm ]
            [ label [ class "basic-label" ] [ text "Username/Email" ]
            , input
                [ type_ "text"
                , placeholder "Username/Email"
                , value model.username
                , onInput SetUsername
                ]
                []
            , label [ class "basic-label" ] [ text "Password" ]
            , input
                [ type_ "password"
                , placeholder "Password"
                , value model.password
                , onInput SetPassword
                ]
                []
            , button [ class "basic-button" ]
                [ text "Sign in" ]
            ]
        ]


viewError : String -> Html Msg
viewError err =
    div [ class "error" ] [ text <| "Error: " ++ err ]
