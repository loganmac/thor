module Page.User.Delete exposing (..)

-- TODO: not implemented.

import Html exposing (Html, button, div, strong, text)
import Html.Attributes exposing (class)


-- MODEL


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    {} ! []



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
    div [ class "user-delete" ]
        [ div [ class "warning" ]
            [ strong [] [ text "!" ], text "DANGER ZONE", strong [] [ text "!" ] ]
        , div [ class "subtext" ] [ text "BEWARE! THIS CANNOT BE UNDONE!" ]
        , button [ class "basic-button danger-inverse" ] [ text "Delete Account" ]
        ]
