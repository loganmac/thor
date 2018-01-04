module Page.App.Delete exposing (..)

import Data.App exposing (App)
import Html exposing (Html, button, div, strong, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


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
    = DeleteApp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DeleteApp ->
            --TODO: make this do the whole confirm dialog, then delete app
            model ! []



-- VIEW


view : Model -> App -> Html Msg
view model app =
    div [ class "app-delete" ]
        [ div [ class "warning" ]
            [ strong [] [ text "!" ], text "DANGER ZONE", strong [] [ text "!" ] ]
        , div [ class "subtext" ] [ text "BEWARE! THIS CANNOT BE UNDONE!" ]
        , button [ class "basic-button danger-inverse", onClick DeleteApp ] [ text "Delete App" ]
        ]
