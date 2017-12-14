module View.Corral exposing (..)

import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Util exposing ((=>))


-- MODEL


type alias Corral =
    { activeItem : String
    }


type alias Id =
    String



-- VIEW


view : Corral -> String -> (Id -> msg) -> List ( Id, Html msg ) -> Html msg
view model title toMsg inner =
    div [ class "corral" ]
        [ div [ class "nav" ]
            [ div [ class "section-title" ]
                [ text title ]
            , div [ class "nav-bar" ] <|
                List.map (viewNavItem model toMsg) inner
            ]
        , div [ class "content" ]
            [ div [ class "section-title" ] [ text model.activeItem ]
            , div [ class "content" ] <|
                List.map viewTabContent <|
                    List.filter (\( i, _ ) -> model.activeItem == i) inner
            ]
        ]


viewNavItem : Corral -> (Id -> msg) -> ( Id, Html msg ) -> Html msg
viewNavItem model toMsg ( id, _ ) =
    div
        [ classList
            [ "nav-item" => True
            , "active" => id == model.activeItem
            ]
        , onClick <| toMsg id
        ]
        [ text id ]


viewTabContent : ( Id, Html msg ) -> Html msg
viewTabContent ( id, content ) =
    div [ class "content-item" ]
        [ content ]
