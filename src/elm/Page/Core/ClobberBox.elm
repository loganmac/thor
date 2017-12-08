module Page.Core.ClobberBox exposing (..)

import AnimationFrame as AnimationFrame
import Html exposing (Attribute, Html, a, div, li, text, ul)
import Html.Attributes exposing (class, classList, href, id, style)
import Html.Events exposing (onClick)


-- TYPES


type Visibility
    = Hidden
    | Start
    | Showing


type NavPosition
    = Below
    | Left


type alias Config msg =
    { toMsg : Model -> msg
    , tabs : List (Tab msg)
    , withAnimation : Bool
    , attributes : List (Html.Attribute msg)
    }


type alias Tab msg =
    { id : String
    , link : Link msg
    , pane : Pane msg
    }


type alias Link msg =
    { attributes : List (Html.Attribute msg)
    , children : List (Html.Html msg)
    }


type alias Pane msg =
    { attributes : List (Html.Attribute msg)
    , children : List (Html.Html msg)
    }



-- MODEL


type alias Model =
    { activeTab : Maybe String
    , visibility : Visibility
    }


{-| Use this function to create the inital state for the tabs control
-}
init : Model
init =
    { activeTab = Nothing
    , visibility = Showing
    }


{-| Use this function if you want to initialize your tabs control with a specific tab selected.
-}
initWithActiveTab : String -> Model
initWithActiveTab id =
    { activeTab = Just id
    , visibility = Showing
    }


{-| Create an initial/default view configuration for a Tab.
-}
config : (Model -> msg) -> Config msg
config toMsg =
    { toMsg = toMsg
    , tabs = []
    , withAnimation = False
    , attributes = []
    }


{-| Define the tab items for a Tab.
-}
tabs : List (Tab msg) -> Config msg -> Config msg
tabs tabs config =
    { config | tabs = tabs }


{-| Use this function when you need additional customization with Html.Attribute attributes for the tabs control
-}
attrs : List (Html.Attribute msg) -> Config msg -> Config msg
attrs attrs config =
    { config | attributes = config.attributes ++ attrs }


{-| Option to add a fade in/out animation effect when switching tabs
-}
withAnimation : Config msg -> Config msg
withAnimation config =
    { config | withAnimation = True }


{-| When using animations you **must** remember to wire up this function to your main subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
Sub.batch
[ Tab.subscriptions model.tabState TabMsg
-- ...other subscriptions you might have
][ Tab.subscriptions model.tabState TabMsg
--  ...other subscriptions you might have
]
-}
subscriptions : Model -> (Model -> msg) -> Sub msg
subscriptions model toMsg =
    case model.activeTab of
        Just _ ->
            AnimationFrame.times
                (\_ -> toMsg model)

        Nothing ->
            Sub.none



-- VIEW
{--| Creates a `ClobberBox` which keeps track of the selected tab and
displays the corresponding content. Ex:

  ClobberBox.view model.clobberBox
    <| ClobberBox.withAnimation -- remember to wire up subscriptions when using this option
    <| ClobberBox.tabs
        [ ClobberBox.tab
            { id = "item1"
            , link = ClobberBox.link [] [ text "Tab 1"]
            , pane = Tab.pane [] [text "Tab 1 Content"]
            }
        , ClobberBox.tab
            { id = "item2"
            , link = ClobberBox.link [] [text "Tab 2"]
            , pane = Tab.pane [] [text "Tab 2 Content"]
            }
        ]
    <| ClobberBox.config ClobberBoxMsg
-}


view : Model -> Config msg -> Html msg
view model config =
    div [ class "box" ]
        [ div [ class "main-content" ]
            [ div [ class "white-box" ] []
            ]
        , div []
            [ ul [ class "nav-holder" ]
                (List.map (renderLink model.activeTab model config) config.tabs)
            , div [ class "sub has-content" ]
                (List.map (renderPane model.activeTab model config) config.tabs)
            ]
        ]


renderLink : Maybe String -> Model -> Config msg -> Tab msg -> Html msg
renderLink activeTabId model config currentTab =
    let
        isActive =
            currentTab.id == Maybe.withDefault "" activeTabId
    in
    li [ class "nav-item" ]
        [ a
            ([ classList [ ( "nav-link", True ), ( "active", isActive ) ]
             , href <| "#" ++ currentTab.id
             , onClick (transitionHandler (Just currentTab.id) config.toMsg model config.withAnimation)
             ]
                ++ currentTab.link.attributes
            )
            currentTab.link.children
        ]


renderPane : Maybe String -> Model -> Config msg -> Tab msg -> Html msg
renderPane activeTabId model config currentTab =
    let
        activeTabAttributes =
            case model.visibility of
                Hidden ->
                    [ style [ ( "display", "none" ) ] ]

                Start ->
                    [ style [ ( "display", "block" ), ( "opacity", "0" ) ] ]

                Showing ->
                    [ style
                        [ ( "display", "block" )
                        , ( "opacity", "1" )
                        , ( "-webkit-transition", "opacity 0.15s linear" )
                        , ( "-o-transition", "opacity 0.15s linear" )
                        , ( "transition", "opacity 0.15s linear" )
                        ]
                    ]

        isActive =
            currentTab.id == Maybe.withDefault "" activeTabId

        displayAttrs =
            if isActive then
                activeTabAttributes
            else
                [ style [ ( "display", "none" ) ] ]
    in
    div ([ id currentTab.id, class "tab-pane" ] ++ displayAttrs)
        currentTab.pane.children


transitionHandler : Maybe String -> (Model -> msg) -> Model -> Bool -> msg
transitionHandler tabId toMsg model shouldAnimate =
    toMsg
        { model
            | activeTab = tabId
            , visibility = setVisiblity shouldAnimate model.visibility
        }


setVisiblity : Bool -> Visibility -> Visibility
setVisiblity shouldAnimate currentVisibility =
    case ( shouldAnimate, currentVisibility ) of
        ( True, Hidden ) ->
            Start

        _ ->
            Showing


{-| Create a composable tab

  - `id` A unique id for the tab
  - `link` The link/menu for the tab
  - `pane` The content part of a tab

-}
tab : { id : String, link : Link msg, pane : Pane msg } -> Tab msg
tab { id, link, pane } =
    Tab id link pane


{-| Creates a composable tab menu item

  - `attributes` List of attributes
  - `children` List of child elements

-}
link : List (Attribute msg) -> List (Html msg) -> Link msg
link attributes children =
    Link attributes children


{-| Creates a composable tab menu pane

  - `attributes` List of attributes
  - `children` List of child elements

-}
pane : List (Attribute msg) -> List (Html msg) -> Pane msg
pane attributes children =
    Pane attributes children
