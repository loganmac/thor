module Page.AppDash exposing (..)

import Html exposing (Attribute, Html, div, h1, h2, header, label, text)
import Html.Attributes exposing (class, disabled, id, placeholder, style)
import Page.Core.TabContainer as TabContainer


type alias Model =
    { tabContainers : List TabContainer.Model
    }


init : ( Model, Cmd msg )
init =
    ( { tabContainers = [] }, Cmd.none )



-- SUBSCRIPTIONS
-- as you can see, you have to specifically wire up every subscription for a tabContainer


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map (TabContainerMsg "1")
            (TabContainer.subscriptions
                (TabContainer.findTabContainer "1" model.tabContainers)
            )
        ]



-- UPDATE


type Msg
    = TabContainerMsg TabContainer.Id TabContainer.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TabContainerMsg containerId subMsg ->
            let
                ( updatedTabContainer, tabContainerCmd ) =
                    TabContainer.update subMsg
                        (TabContainer.findTabContainer containerId model.tabContainers)
            in
            ( { model
                | tabContainers =
                    TabContainer.updateTabContainer updatedTabContainer model.tabContainers
              }
            , Cmd.map (TabContainerMsg containerId) tabContainerCmd
            )



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
                        [ Html.map (TabContainerMsg "container1") (tabs "container1" model)
                        ]
                    ]
                ]
            ]
        ]


tabs : String -> Model -> Html TabContainer.Msg
tabs id model =
    TabContainer.view (TabContainer.findTabContainer id model.tabContainers)
        TabContainer.FadeOut
        [ TabContainer.tab []
            { id = "item1"
            , link = TabContainer.link [] [ text "Tab 1" ]
            , pane = TabContainer.pane [] [ div [ class "medium-block" ] [] ]
            }
        , TabContainer.tab []
            { id = "item2"
            , link = TabContainer.link [] [ text "Tab 2" ]
            , pane = TabContainer.pane [] [ div [ class "huge-block" ] [] ]
            }
        , TabContainer.tab []
            { id = "item3"
            , link = TabContainer.link [] [ text "Tab 3" ]

            -- , pane = Tabs.pane [] [ div [ class "small-block" ] [] ]
            , pane = TabContainer.pane [ class "small-block" ] [ tabs2 "container2" model ]
            }
        ]


tabs2 : String -> Model -> Html TabContainer.Msg
tabs2 id model =
    TabContainer.view (TabContainer.findTabContainer id model.tabContainers)
        TabContainer.FadeOut
        [ TabContainer.tab []
            { id = "item1"
            , link = TabContainer.link [] [ text "Tab 1" ]
            , pane = TabContainer.pane [] [ div [ class "medium-block" ] [] ]
            }
        , TabContainer.tab []
            { id = "item2"
            , link = TabContainer.link [] [ text "Tab 2" ]
            , pane = TabContainer.pane [] [ div [ class "huge-block" ] [] ]
            }
        , TabContainer.tab []
            { id = "item3"
            , link = TabContainer.link [] [ text "Tab 3" ]
            , pane = TabContainer.pane [] [ div [ class "small-block" ] [] ]
            }
        ]
