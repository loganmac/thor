module Page.App.Deploy exposing (..)

import Data.App as App exposing (App)
import Html exposing (Html, button, div, strong, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Util exposing ((=>))
import View.Lexi as Lexi


-- MODEL


type alias Model =
    { shouldBoxfileUpdate : Maybe Bool
    , settings :
        { shouldBoxfileUpdate : Bool }
    }


init : ( Model, Cmd Msg )
init =
    { shouldBoxfileUpdate = Nothing
    , settings = { shouldBoxfileUpdate = True }
    }
        ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


type Msg
    = ToggleBoxfileUpdate Bool
    | CancelDeploySettings
    | SaveDeploySettings Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- TODO: Make http request once endpoint documentation exists.
        ToggleBoxfileUpdate bool ->
            { model | shouldBoxfileUpdate = Just bool } ! []

        CancelDeploySettings ->
            { model | shouldBoxfileUpdate = Nothing } ! []

        -- TODO: Make http request once endpoint documentation exists.
        SaveDeploySettings bool ->
            { model
                | shouldBoxfileUpdate = Nothing
                , settings = { shouldBoxfileUpdate = bool }
            }
                ! []



-- VIEW


view : Model -> App -> Html Msg
view model app =
    let
        -- TODO: Get settings here from API
        saveButtons shouldUpdate =
            div [ class "save-section" ]
                [ button
                    [ class "basic-button cancel"
                    , onClick CancelDeploySettings
                    ]
                    [ text "Cancel" ]
                , button
                    [ class "basic-button"
                    , onClick <| SaveDeploySettings shouldUpdate
                    ]
                    [ text "Save" ]
                ]

        ( shouldUpdate, saveSection ) =
            case model.shouldBoxfileUpdate of
                Just shouldUpdate ->
                    shouldUpdate => saveButtons shouldUpdate

                Nothing ->
                    model.settings.shouldBoxfileUpdate => div [] []
    in
    div [ class "app-deploy" ]
        [ Lexi.checkbox (ToggleBoxfileUpdate <| not shouldUpdate)
            shouldUpdate
            [ text "On deploy, if a data component's "
            , strong [] [ text "boxfile.yml" ]
            , text " config settings have changed, rebuild it."
            ]
        , saveSection
        ]
