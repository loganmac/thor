module Page.Auth.Register exposing (..)

import Html exposing (Html, div, text)


-- MODEL


type alias Model =
    {}



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []



-- VIEW


view : Model -> Html Msg
view model =
    div [] [ text "Register page: not implemented" ]
