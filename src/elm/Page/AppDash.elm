module Page.AppDash exposing (..)

import Html exposing (Attribute, Html, div, h2, header, label, text)
import Html.Attributes exposing (class, disabled, id, placeholder, style)
import Page.Core.ClobberBox as ClobberBox


type alias Model =
    { clobber1 : ClobberBox.Model
    , clobber2 : ClobberBox.Model
    }


init : ( Model, Cmd msg )
init =
    ( { clobber1 = ClobberBox.init
      , clobber2 = ClobberBox.init
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Clobber1Msg ClobberBox.Model
    | Clobber2Msg ClobberBox.Model


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        Clobber1Msg cbModel ->
            ( { model | clobber1 = cbModel }, Cmd.none )

        Clobber2Msg cbModel ->
            ( { model | clobber2 = cbModel }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ header [ class "header", id "dashboard-header", style [ ( "height", "40px" ) ] ] []
        , div
            [ class "layout", id "dashboard-layout" ]
            [ div [ class "layout-header" ] []
            , div [ class "layout-container", id "apps-dash" ]
                [ div [ class "columns col_left eight" ]
                    [ div [ class "row", id "service-index" ]
                        [ h2 [] [ text "Service-specific Server Names" ]
                        , div [ id "valkrie" ]
                            [ div [ class "boxes" ]
                                [ basicClobber model.clobber1 Clobber1Msg
                                , animatedClobber model.clobber2 Clobber2Msg
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


basicClobber : ClobberBox.Model -> (ClobberBox.Model -> msg) -> Html msg
basicClobber model toMsg =
    ClobberBox.view model <|
        ClobberBox.tabs
            [ ClobberBox.tab
                { id = "item1"
                , link = ClobberBox.link [] [ text "Tab 1" ]
                , pane = ClobberBox.pane [] [ text "Tab 1 Content" ]
                }
            , ClobberBox.tab
                { id = "item2"
                , link = ClobberBox.link [] [ text "Tab 2" ]
                , pane = ClobberBox.pane [] [ text "Tab 2 Content" ]
                }
            ]
        <|
            ClobberBox.config toMsg



-- ClobberBox.view model.clobberBox {}


animatedClobber : ClobberBox.Model -> (ClobberBox.Model -> msg) -> Html msg
animatedClobber model toMsg =
    ClobberBox.view model <|
        ClobberBox.withAnimation <|
            ClobberBox.tabs
                [ ClobberBox.tab
                    { id = "item1"
                    , link = ClobberBox.link [] [ text "Tab 1" ]
                    , pane = ClobberBox.pane [] [ text "Tab 1 Content" ]
                    }
                , ClobberBox.tab
                    { id = "item2"
                    , link = ClobberBox.link [] [ text "Tab 2" ]
                    , pane = ClobberBox.pane [] [ text "Tab 2 Content" ]
                    }
                ]
            <|
                ClobberBox.config toMsg
