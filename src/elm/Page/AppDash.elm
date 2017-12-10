module Page.AppDash exposing (..)

import Dict exposing (Dict)
import Html exposing (Attribute, Html, div, h1, h2, header, label, text)
import Html.Attributes exposing (class, disabled, id, placeholder, style)
import Page.Core.TabContainer as TC


type alias Model =
    { containers : Dict String TC.Model
    }



-- here we are initializing the state. In the real app,
-- we would make an api call to fetch the data, then use the returned
-- data to initialize TabContainers


init : ( Model, Cmd msg )
init =
    ( { containers = Dict.empty }
    , Cmd.none
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch (List.map mapSub (Dict.toList model.containers))


mapSub : ( String, TC.Model ) -> Sub Msg
mapSub ( id, container ) =
    Sub.map (TabContainerMsg id) (TC.subscriptions container)



-- UPDATE


type Msg
    = TabContainerMsg String TC.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "msg" msg of
        TabContainerMsg containerId subMsg ->
            let
                ( updatedTabContainer, tabContainerCmd ) =
                    TC.update subMsg
                        (TC.findTabContainer containerId model.containers)
            in
            ( { model
                | containers =
                    TC.updateTabContainer updatedTabContainer model.containers
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
                        [ tabContainer model ]
                    ]
                ]
            ]
        ]


tabContainer : Model -> Html Msg
tabContainer model =
    tabs "container1" (Debug.log "model" model)
        |> Html.map (TabContainerMsg "container1")


tabs : String -> Model -> Html TC.Msg
tabs id model =
    let
        containerModel =
            TC.findTabContainer id model.containers
    in
    TC.view containerModel
        TC.FadeOut
        [ TC.tab []
            { id = "item1"
            , link = TC.link [] [ text "Tab 1" ]
            , pane = TC.pane [] [ div [ class "medium-block" ] [] ]
            }
        , TC.tab []
            { id = "item2"
            , link = TC.link [] [ text "Tab 2" ]
            , pane = TC.pane [] [ div [ class "huge-block" ] [] ]
            }
        , TC.tab []
            { id = "item3"
            , link = TC.link [] [ text "Tab 3" ]

            -- , pane = TabContainer.pane [] [ div [ class "small-block" ] [] ]
            , pane = TC.pane [ class "small-block" ] [ subcontainerExample "container2" containerModel ]
            }
        ]


subcontainerExample : String -> TC.Model -> Html TC.Msg
subcontainerExample id (TC.Model model) =
    let
        containerModel =
            TC.findTabContainer id model.containers
    in
    TC.view containerModel
        (TC.subMsg id TC.FadeOut)
        [ TC.tab []
            { id = "item1"
            , link = TC.link [] [ text "Tab 1" ]
            , pane = TC.pane [] [ div [ class "medium-block" ] [] ]
            }
        , TC.tab []
            { id = "item2"
            , link = TC.link [] [ text "Tab 2" ]
            , pane = TC.pane [] [ div [ class "huge-block" ] [] ]
            }
        , TC.tab []
            { id = "item3"
            , link = TC.link [] [ text "Tab 3" ]
            , pane = TC.pane [] [ div [ class "small-block" ] [] ]
            }
        ]
