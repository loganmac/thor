module Page.AppDash exposing (..)

import Dict exposing (Dict)
import Html exposing (Attribute, Html, div, h1, h2, header, label, text)
import Html.Attributes exposing (class, disabled, id, placeholder, style)
import Page.Core.TabContainer as TabContainer


type alias Model =
    { tabContainers : Dict String TabContainer.Model
    }



-- here we are initializing the state. In the real app,
-- we would make an api call to fetch the data, then use the returned
-- data to initialize TabContainers


init : ( Model, Cmd msg )
init =
    ( { tabContainers = Dict.fromList [ TabContainer.init "container1" ] }
    , Cmd.none
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch (List.map mapSub (Dict.toList model.tabContainers))


mapSub : ( String, TabContainer.Model ) -> Sub Msg
mapSub ( id, container ) =
    Sub.map (TabContainerMsg id) (TabContainer.subscriptions container)



-- UPDATE


type Msg
    = TabContainerMsg String TabContainer.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "msg" msg of
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
                        [ Html.map (TabContainerMsg "container1") <|
                            tabs "container1" (Debug.log "model" model) TabContainer.FadeOut
                        ]
                    ]
                ]
            ]
        ]


tabs : String -> Model -> TabContainer.ToMsg msg -> Html msg
tabs id model toMsg =
    TabContainer.view (TabContainer.findTabContainer id model.tabContainers)
        toMsg
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

            -- , pane = TabContainer.pane [] [ div [ class "small-block" ] [] ]
            , pane = TabContainer.pane [ class "small-block" ] [ tabs2 "container2" model toMsg ]
            }
        ]


tabs2 : String -> Model -> TabContainer.ToMsg msg -> Html msg
tabs2 id model toMsg =
    TabContainer.view (TabContainer.findTabContainer id model.tabContainers)
        toMsg
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
