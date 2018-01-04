module Page.App.Update exposing (..)

import Data.App exposing (App)
import Html exposing (Html, button, div, text)
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
    = UpdateAgent
    | SyncProvider


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- TODO: Make http request once endpoint documentation exists.
        UpdateAgent ->
            model ! []

        -- TODO: Make http request once endpoint documentation exists.
        SyncProvider ->
            model ! []



-- VIEW


view : Model -> App -> Html Msg
view model app =
    div [ class "app-update" ]
        [ div [ class "section" ]
            [ button [ class "basic-button", onClick UpdateAgent ] [ text "Update Agent" ]
            , div [ class "button-text" ]
                [ text "Nanobox installs a small communication agent on each of "
                , text "your servers. Updating cycles through each and ensures "
                , text "they are updated with the latest stable release."
                ]
            ]
        , div [ class "section" ]
            [ button [ class "basic-button", onClick SyncProvider ] [ text "Sync Provider" ]
            , div [ class "button-text" ]
                [ text "On order, Nanobox stores information about each of your "
                , text "servers. This info can get out of sync if the provider "
                , text "changes the IP address after stop/start. Syncing ensures "
                , text "our record is updated and in harmony with your provider."
                ]
            ]
        ]
