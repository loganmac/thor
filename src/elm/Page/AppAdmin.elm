module Page.AppAdmin exposing (..)

import Data.App as App exposing (App)
import Html exposing (Attribute, Html, div, form, h2, input, label, text)
import Html.Attributes exposing (class, disabled, for, id, placeholder, required, type_, value)
import Http
import Util exposing ((=>))
import View.Corral as Corral
import View.Material as Material


-- MODEL


type alias Model =
    { app : App
    , corral : Corral.Corral
    }


init : ( Model, Cmd Msg )
init =
    ( { app = App.initialModel
      , corral = { activeItem = "App Info" }
      }
    , App.getApp "c3bff5fd-ce3e-4bfb-8ecc-f43714a3fc44" GetAppResponse
    )



-- UPDATE


type Msg
    = CorralItemClicked String
    | GetAppResponse (Result Http.Error App)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ corral } as model) =
    case msg of
        CorralItemClicked str ->
            let
                updatedCorral =
                    { corral | activeItem = str }
            in
            ( { model | corral = updatedCorral }, Cmd.none )

        GetAppResponse (Ok app) ->
            ( { model | app = app }, Cmd.none )

        GetAppResponse (Err error) ->
            Debug.log (toString error)
                ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "app-admin" ]
        [ Corral.view model.corral "App Admin" CorralItemClicked <|
            [ "Info" => viewAppInfo model
            , "Ownership" => div [] []
            , "Deploy" => div [] []
            , "Update" => div [] []
            , "Security" => div [] []
            , "Delete" => div [] []
            ]
        ]


navItem : String -> Html msg
navItem txt =
    div [ class "item" ]
        [ text txt
        ]


viewAppInfo : Model -> Html msg
viewAppInfo model =
    div []
        [ h2 [] [ text "App Info" ]
        , label [] [ text "Name" ]
        , input [ type_ "text", placeholder "App Name", value model.app.name ] []
        , label [] [ text "Provider" ]
        , input [ type_ "text", disabled True, placeholder "Provider", value model.app.providerName ] []
        , label [] [ text "Region" ]
        , input [ type_ "text", disabled True, placeholder "Region", value model.app.platformRegion ] []
        , Material.input [] [ text "Material" ]
        ]
