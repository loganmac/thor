module Page.Core.Tabs exposing (..)

import Html exposing (Attribute, Html, a, div, li, text, ul)
import Html.Attributes exposing (class, classList, href, id, style)
import Html.Events exposing (onClick)
import Maybe.Extra


-- TYPES


type Visibility
    = FadingOut
    | FadingIn
    | Visible


type alias Clobber msg =
    { attributes : List (Attribute msg)
    , activeTab : Tab msg
    , id : String
    }


type alias Tab msg =
    { attributes : List (Attribute msg)
    , id : String
    , link : Link msg
    , pane : Pane msg
    , visibility : Visibility
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
    { id : String
    , activeTab : Maybe String
    }


{-| Use this function to create the inital state for the tabs control
-}
init : String -> Model
init id =
    { id = id
    , activeTab = Nothing
    }


{-| Use this function if you want to initialize your tabs control with a specific tab selected.
-}
initWithActiveTab : String -> String -> Model
initWithActiveTab id activeId =
    { id = id
    , activeTab = Just activeId
    }



-- VIEW


view : Model -> (Model -> msg) -> List (Tab msg) -> Html msg
view model toMsg tabs =
    div []
        [ ul [ class "tab-links" ]
            (List.map (viewLink model.activeTab model toMsg) tabs)
        , div [ classList [ ( "sub", True ), ( "has-content", Maybe.Extra.isJust model.activeTab ) ] ]
            (List.map (viewPane model.activeTab model) tabs)
        ]


viewLink : Maybe String -> Model -> (Model -> msg) -> Tab msg -> Html msg
viewLink activeTabId model toMsg currentTab =
    let
        isActive =
            currentTab.id == Maybe.withDefault "" activeTabId
    in
    li
        [ classList [ ( "tab-link", True ), ( "active", isActive ) ]
        , onClick <| clickHandler (Just currentTab.id) toMsg model
        ]
        [ a
            ([ href <| "#" ++ currentTab.id ]
                ++ currentTab.link.attributes
            )
            currentTab.link.children
        ]


viewPane : Maybe String -> Model -> Tab msg -> Html msg
viewPane activeTabId model currentTab =
    let
        isActive =
            currentTab.id == Maybe.withDefault "" activeTabId

        displayAttrs =
            if isActive then
                [ style [ ( "display", "block" ) ] ]
            else
                [ style [ ( "display", "none" ) ] ]
    in
    div ([ id currentTab.id, class "tab-pane" ] ++ displayAttrs)
        currentTab.pane.children


clickHandler : Maybe String -> (Model -> msg) -> Model -> msg
clickHandler activeId toMsg model =
    toMsg { model | activeTab = activeId }


{-| Create a composable tab

  - `id` A unique id for the tab
  - `link` The link/menu for the tab
  - `pane` The content part of a tab

-}
tab : List (Attribute msg) -> { id : String, link : Link msg, pane : Pane msg } -> Tab msg
tab attributes { id, link, pane } =
    Tab attributes id link pane Visible


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


findTabs : String -> List Model -> Model
findTabs id modelList =
    case List.head <| List.filter (\x -> x.id == id) modelList of
        Nothing ->
            { id = id, activeTab = Nothing }

        Just tabs ->
            tabs
