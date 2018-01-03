module Page.App.Info exposing (..)

-- TODO: not implemented.

import Flag
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Util exposing ((=>))
import View.AuthedPage as Page


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


view : Flag.Flags -> Model -> Html Msg
view flags model =
    Page.view flags <| div [ class "app-info" ] []
