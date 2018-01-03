module Page.Dashboard exposing (..)

import Data.User as User exposing (User)
import Html exposing (Attribute, Html, a, button, div, hr, input, label, option, select, strong, text)
import Html.Attributes exposing (class, classList, disabled, id, placeholder, selected, type_, value)
import Html.Events exposing (onClick, onInput)
import Util exposing ((=>))
import View.Lexi as Lexi


-- MODEL


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    {} ! []



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
    div [ class "dashboard" ] []
