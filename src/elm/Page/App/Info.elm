module Page.App.Info exposing (..)

import Data.App as App exposing (App)
import Html exposing (Html, div, input, label, text)
import Html.Attributes exposing (class, disabled, placeholder, type_, value)
import Html.Events exposing (onInput)
import View.Lexi as Lexi


-- MODEL


type alias Model =
    { newAppName : Maybe String }


init : ( Model, Cmd Msg )
init =
    { newAppName = Nothing } ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


type Msg
    = NewAppName String
    | CancelNewAppName
    | SaveNewAppName


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewAppName name ->
            { model | newAppName = Just name } ! []

        CancelNewAppName ->
            { model | newAppName = Nothing } ! []

        -- TODO: Make http request once endpoint documentation exists.
        SaveNewAppName ->
            { model | newAppName = Nothing } ! []



-- VIEW


view : Model -> App -> Html Msg
view model app =
    let
        appName =
            case model.newAppName of
                Nothing ->
                    app.name

                Just name ->
                    name
    in
    div [ class "app-info" ]
        [ label [ class "basic-label" ] [ text "Name" ]
        , input
            [ type_ "text"
            , placeholder "App Name"
            , value appName
            , onInput NewAppName
            ]
            []
        , Lexi.saveSection
            (model.newAppName == Just app.name || model.newAppName == Nothing)
            CancelNewAppName
            SaveNewAppName
        , label [ class "basic-label" ] [ text "Provider" ]
        , input
            [ type_ "text"
            , disabled True
            , placeholder "Provider"
            , value app.providerName
            ]
            []
        , label [ class "basic-label" ] [ text "Region" ]
        , input
            [ type_ "text"
            , disabled True
            , placeholder "Region"
            , value app.platformRegion
            ]
            []
        ]
