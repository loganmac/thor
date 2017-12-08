module Page.Core.FlexWrapper exposing (..)

import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


-- MODEL


type alias Model =
    { title : String
    , nav : List String
    , value : String
    , activeItem : String
    }



-- VIEW


view : Model -> (String -> msg) -> Html msg -> Html msg
view model itemClick inner =
    div [ class "corral" ]
        [ div [ class "left-nav" ]
            [ div [ class "section-title" ]
                [ text model.title
                ]
            , div [ class "nav" ] <| List.map (navItem itemClick) model.nav
            ]
        , div [ class "content" ]
            [ div [ class "section-title" ] [ text model.activeItem ]
            , inner
            ]
        ]


navItem : (String -> msg) -> String -> Html msg
navItem event txt =
    div [ class "item", onClick <| event txt ]
        [ text txt
        ]
