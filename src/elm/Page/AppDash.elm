module Page.AppDash exposing (..)

import Html exposing (Attribute, Html, div, h1, h2, header, label, text)
import Html.Attributes exposing (class, disabled, id, placeholder, style)
import Page.Core.Tabs as Tabs


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
            ( { model | tabs = [ tabsModel ] }, Cmd.none )



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
                        [ basicClobber (Tabs.findTabs "1" model.tabs) TabsMsg
                        ]
                    ]
                ]
            ]
        ]


basicClobber : Tabs.Model -> (Tabs.Model -> msg) -> Html msg
basicClobber model toMsg =
    Tabs.view model
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
