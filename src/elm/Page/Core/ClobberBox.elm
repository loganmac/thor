module Page.Core.ClobberBox exposing (..)

import AnimationFrame as AnimationFrame
import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


-- MODEL


type alias Model =
    { activeTab : Maybe String
    }


init : Model
init =
    { activeTab = Nothing
    }


type Tab msg
    = Tab
        { id : String
        , link : TabLink msg
        , pane : TabContent msg
        }


type TabLink msg
    = TabLink
        { attributes : List (Html.Attribute msg)
        , children : List (Html.Html msg)
        }


type TabContent msg
    = TabContent
        { attributes : List (Html.Attribute msg)
        , children : List (Html.Html msg)
        }



--
-- subscriptions : Model -> (Model -> msg) -> Sub msg
-- subscriptions model toMsg =
--     case model.activeTab of
--         Just _ ->
--             AnimationFrame.times
--                 (\_ -> toMsg model)
--
--         Nothing ->
--             Sub.none
--
--
--
-- -- VIEW
--
--
-- view : Model -> (String -> msg) -> Html msg -> Html msg
-- view ({ activeTab } as model) itemClick inner =
--     let
--         content =
--             case activeTab of
--                 Nothing ->
--                     div [] []
--
--                 Just (Tab currentTab) ->
--                     inner
--     in
--     div [ class "box" ]
--         [ div [ class "main-content" ]
--             [ div [ class "white-box" ] []
--             ]
--         , div [ class "nav-holder" ] []
--         , div [ class "sub has-content" ] [ inner ]
--         ]
--
--
-- boxContent : (String -> msg) -> String -> Html msg
-- boxContent event txt =
--     div [ class "item", onClick <| event txt ]
--         [ text txt
--         ]
