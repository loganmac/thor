module View.Corral exposing (..)

import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


-- MODEL


type alias Corral =
    { title : String
    , nav : List String
    , value : String
    , activeItem : String
    }



-- VIEW


view : Corral -> (String -> msg) -> Html msg -> Html msg
view model itemClick inner =
    div [ class "corral" ]
        [ div [ class "corral-nav" ]
            [ div [ class "corral-section-title" ]
                [ text model.title ]
            , div [ class "corral-nav-bar" ] <| List.map (navItem itemClick) model.nav
            ]
        , div [ class "corral-content" ]
            [ div [ class "corral-section-title" ] [ text model.activeItem ]
            , inner
            ]
        ]


navItem : (String -> msg) -> String -> Html msg
navItem toMsg txt =
    div [ class "corral-nav-item", onClick <| toMsg txt ]
        [ text txt
        ]
