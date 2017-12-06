module Main exposing (..)

-- import Html.Attributes exposing (..)

import Html exposing (Html, br, div, p, text)
import Html.Attributes exposing (class)
import Lexi.Simple.Checkbox as SimpleCheckbox
import Lexi.Styled.Checkbox as StyledCheckbox
import Lexi.Styled.Label as StyledLabel
import Page.AppAdmin as AppAdmin
import Page.Core.Corral as Corral
import Page.Core.TopNav as TopNav


-- import Http
-- import Json.Decode as Decode


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }


type alias Model =
    { corral : Corral.Model
    , isTesting : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { corral =
            { title = "App Admin"
            , nav = [ "Info", "Ownership", "Deploy", "Update", "Security", "Delete" ]
            , value = "App Admin"
            , activeItem = ""
            }
      , isTesting = False
      }
    , Cmd.none
    )


type Msg
    = CorralItemClicked String
    | CheckedTesting


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ corral } as model) =
    case msg of
        CorralItemClicked str ->
            let
                updatedCorral =
                    { corral | activeItem = str }
            in
            ( { model | corral = updatedCorral }, Cmd.none )

        CheckedTesting ->
            ( { model | isTesting = not model.isTesting }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "main" ]
        [ TopNav.view (text "")
        , AppAdmin.view CorralItemClicked model.corral
        , div [ class "holder lexi" ]
            [ div [ class "checkboxes" ]
                [ StyledCheckbox.checkbox
                    { msg = CheckedTesting
                    , isChecked = model.isTesting
                    , labelPosition = StyledCheckbox.LabelBefore
                    , label = StyledLabel.lightLabel [ text "Light, with a label before, styled like a vue component" ]
                    , theme = StyledCheckbox.Light
                    }
                , br [] []
                , div [ class "lexi lexi-blue" ]
                    [ StyledCheckbox.checkbox
                        { msg = CheckedTesting
                        , isChecked = model.isTesting
                        , labelPosition = StyledCheckbox.LabelAfter
                        , label = StyledLabel.lightLabel [ text "Dark, with a label after, styled like a vue component" ]
                        , theme = StyledCheckbox.Dark
                        }
                    ]
                , br [] []
                , div [ class "lexi" ]
                    [ SimpleCheckbox.checkbox
                        { msg = CheckedTesting
                        , isChecked = model.isTesting
                        , labelPosition = SimpleCheckbox.LabelBefore
                        , text = "Light, with a label before, styled with scss and class names"
                        }
                    ]
                , div [ class "lexi lexi-blue" ]
                    [ SimpleCheckbox.checkbox
                        { msg = CheckedTesting
                        , isChecked = model.isTesting
                        , labelPosition = SimpleCheckbox.LabelAfter
                        , text = "Dark, with a label after, styled with scss and class names"
                        }
                    ]
                ]
            ]
        ]
