module Page.App.Admin exposing (..)

-- TODO: Refactor out into sub-pages

import Data.App as App exposing (App)
import Html exposing (Attribute, Html, a, button, div, hr, input, label, option, select, strong, text)
import Html.Attributes exposing (class, classList, disabled, id, placeholder, selected, type_, value)
import Html.Events exposing (onClick, onInput)
import Util exposing ((=>))
import View.Corral as Corral
import View.Lexi as Lexi


-- MODEL


type alias Model =
    { corral : Corral.Corral
    , newAppName : Maybe String
    }


init : Model
init =
    { corral = { activeItem = "App Info" } }



-- VIEW


view : Model -> App -> Html Msg
view model app =
    div [ class "app-admin" ]
        [ Corral.view model.corral "Manage App" CorralItemClicked <|
            [ "App Info"
            , "Ownership"
            , "Deploy"
            , "Update Platform"
            , "Security"
            , "Delete"
            ]
        ]
