module Page.App.Evars exposing (..)

-- TODO: not implemented.

import Data.App exposing (App)
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Util exposing ((=>))


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


view : Model -> App -> Html Msg
view model app =
    div [ class "app-evars" ] []
