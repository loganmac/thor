module Page.AppDash exposing (..)

import Html exposing (Attribute, Html, div, h1, h2, header, label, text)
import Html.Attributes exposing (class, disabled, id, placeholder, style)
import Page.Core.Tabs as Tabs
import Ports


type alias Model =
    { tabs : List Tabs.Model
    }


init : ( Model, Cmd msg )
init =
    ( { tabs = [] }, Cmd.none )



-- UPDATE


type Msg
    = TabsMsg Tabs.Model


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        TabsMsg tabsModel ->
            ( { model | tabs = Tabs.updateTabs tabsModel model.tabs }, Cmd.none )



-- SUBSCRIPTIONS
--
-- subscriptions : Model -> Sub Msg
-- subscriptions model =
--     Ports.uuid NewId
-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ header [ class "header", id "dashboard-header", style [ ( "height", "40px" ) ] ] []
        , div
            [ class "layout", id "dashboard-layout" ]
            [ div [ class "layout-header" ] []
            , div []
                [ div [ class "columns col_left eight" ]
                    [ h2 [] [ text "Service-specific Server Names" ]
                    , div [ class "boxes" ]
                        [ topTabs "1" model TabsMsg
                        ]
                    ]
                ]
            ]
        ]


topTabs : String -> Model -> (Tabs.Model -> msg) -> Html msg
topTabs id model toMsg =
    Tabs.view (Tabs.findTabs id model.tabs)
        toMsg
        [ Tabs.tab []
            { id = "item1"
            , link = Tabs.link [] [ text "Tab 1" ]
            , pane = Tabs.pane [] [ innerTabs "2" model toMsg ]
            }
        , Tabs.tab []
            { id = "item2"
            , link = Tabs.link [] [ text "Tab 2" ]
            , pane = Tabs.pane [] [ innerTabs "3" model toMsg ]
            }
        ]


innerTabs : String -> Model -> (Tabs.Model -> msg) -> Html msg
innerTabs id model toMsg =
    Tabs.view (Tabs.findTabs id model.tabs)
        toMsg
        [ Tabs.tab []
            { id = "item1"
            , link = Tabs.link [] [ text "Tab 1" ]
            , pane = Tabs.pane [] [ innermostTabs "4" model toMsg ]
            }
        , Tabs.tab []
            { id = "item2"
            , link = Tabs.link [] [ text "Tab 2" ]
            , pane = Tabs.pane [] [ innermostTabs "5" model toMsg ]
            }
        , Tabs.tab []
            { id = "item3"
            , link = Tabs.link [] [ text "Tab 3" ]
            , pane = Tabs.pane [] [ innermostTabs "6" model toMsg ]
            }
        ]


innermostTabs : String -> Model -> (Tabs.Model -> msg) -> Html msg
innermostTabs id model toMsg =
    Tabs.view (Tabs.findTabs id model.tabs)
        toMsg
        [ Tabs.tab []
            { id = "item1"
            , link = Tabs.link [] [ text "Tab 1" ]
            , pane = Tabs.pane [] [ h1 [] [ text "Tab 1 Content" ] ]
            }
        , Tabs.tab []
            { id = "item2"
            , link = Tabs.link [] [ text "Tab 2" ]
            , pane = Tabs.pane [] [ h1 [] [ text "Tab 2 Content" ] ]
            }
        , Tabs.tab []
            { id = "item3"
            , link = Tabs.link [] [ text "Tab 3" ]
            , pane = Tabs.pane [] [ h1 [] [ text "Tab 3 Content" ] ]
            }
        , Tabs.tab []
            { id = "item4"
            , link = Tabs.link [] [ text "Tab 4" ]
            , pane = Tabs.pane [] [ h1 [] [ text "Tab 4 Content" ] ]
            }
        ]
