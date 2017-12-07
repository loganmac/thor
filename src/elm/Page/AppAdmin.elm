module Page.AppAdmin exposing (..)

import Data.App as App exposing (App)
import Html exposing (Attribute, Html, div, h2, input, label, text)
import Html.Attributes exposing (class, disabled, placeholder, value)
import Http
import Page.Core.Corral as Corral


-- MODEL


type alias Model =
    { app : App
    , corral : Corral.Model
    }


init : ( Model, Cmd Msg )
init =
    ( { app = App.initialModel
      , corral =
            { title = "App Admin"
            , nav = [ "Info", "Ownership", "Deploy", "Update", "Security", "Delete" ]
            , value = "App Admin"
            , activeItem = "Info"
            }
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
        [ Corral.view model.corral CorralItemClicked <|
            div [ class "tab-content" ]
                [ activeTab model ]
        ]


navItem : String -> Html msg
navItem txt =
    div [ class "item" ]
        [ text txt
        ]


activeTab : Model -> Html Msg
activeTab model =
    div []
        [ h2 [] [ text "App Info" ]
        , label []
            [ text "Name"
            , input [ placeholder "App Name" ] []
            ]
        , label []
            [ text "Provider"
            , input [ disabled True, placeholder "Provider", value model.app.providerName ] []
            ]
        , label []
            [ text "Region"
            , input [ disabled True, placeholder "Region", value model.app.platformRegion ] []
            ]
        ]
