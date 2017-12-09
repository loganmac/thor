module Page.Core.TabContainer exposing (..)

import Animation
import Animation.Messenger
import Html exposing (Attribute, Html, a, div, li, text, ul)
import Html.Attributes exposing (class, classList, href, id, style)
import Html.Events exposing (onClick)
import Maybe.Extra


-- TYPES


type alias Id =
    String


type alias Tab msg =
    { attributes : List (Attribute msg)
    , id : String
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
    { id : String
    , activeTab : Maybe String
    , previousTab : Maybe String
    , style : Animation.Messenger.State Msg
    }


{-| Use this function to create the inital state for the tabs control
-}
init : String -> Model
init id =
    { id = id
    , activeTab = Nothing
    , previousTab = Nothing
    , style = initTabContainerStyle
    }


{-| Use this function if you want to initialize your tabs control with a specific tab selected.
-}
initWithActiveTab : String -> String -> Model
initWithActiveTab id activeId =
    { id = id
    , activeTab = Just activeId
    , previousTab = Nothing
    , style = initTabContainerStyle
    }


initTabContainerStyle : Animation.Messenger.State Msg
initTabContainerStyle =
    Animation.style [ Animation.opacity 1.0 ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Animation.subscription (Animate model) [ model.style ]



-- UPDATE


type Msg
    = FadeOut Model
    | Active Model
    | Animate Model Animation.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FadeOut newModel ->
            ( { newModel
                | style =
                    Animation.interrupt
                        [ Animation.to [ Animation.opacity 0 ]
                        , Animation.Messenger.send (Active newModel)
                        ]
                        newModel.style
              }
            , Cmd.none
            )

        Active newModel ->
            ( Debug.log "start" newModel, Cmd.none )

        Animate tabContainerModel animMsg ->
            let
                ( newStyle, animCmd ) =
                    Animation.Messenger.update animMsg tabContainerModel.style
            in
            ( { tabContainerModel | style = newStyle }, animCmd )



-- VIEW


view : Model -> (Model -> msg) -> List (Tab msg) -> Html msg
view model toMsg tabs =
    div []
        [ ul [ class "tab-links" ]
            (List.map (viewLink model toMsg) tabs)
        , div [ classList [ ( "tab-panes", True ), ( "active", Maybe.Extra.isJust model.activeTab ) ] ]
            (List.map (viewPane model) tabs)
        ]


viewLink : Model -> (Model -> msg) -> Tab msg -> Html msg
viewLink model toMsg currentTab =
    let
        isActive =
            currentTab.id == Maybe.withDefault "" model.activeTab
    in
    li
        [ classList [ ( "tab-link", True ), ( "active", isActive ) ]
        , onClick <| clickHandler currentTab.id toMsg model
        ]
        [ a
            ([ href <| "#" ++ currentTab.id ] ++ currentTab.link.attributes)
            currentTab.link.children
        ]


viewPane : Model -> Tab msg -> Html msg
viewPane model currentTab =
    let
        is check =
            currentTab.id == Maybe.withDefault "" (check model)

        displayAttrs =
            if is .activeTab then
                [ class "tab-pane active" ]
            else if is .previousTab then
                [ class "tab-pane previous" ]
            else
                [ class "tab-pane hidden" ]
    in
    div
        (Animation.render model.style
            ++ [ id (model.id ++ "-" ++ currentTab.id) ]
            ++ displayAttrs
            ++ currentTab.pane.attributes
        )
        currentTab.pane.children


clickHandler : String -> (Model -> msg) -> Model -> msg
clickHandler tabId toMsg model =
    toMsg { model | activeTab = Just tabId }


updateTabContainer : Model -> List Model -> List Model
updateTabContainer model modelList =
    if List.any (\a -> a.id == model.id) modelList then
        List.map
            (\a ->
                if a.id == model.id then
                    model
                else
                    a
            )
            modelList
    else
        model :: modelList


findTabContainer : String -> List Model -> Model
findTabContainer id modelList =
    case List.head <| List.filter (\x -> x.id == id) modelList of
        Nothing ->
            { id = id
            , activeTab = Nothing
            , previousTab = Nothing
            , style = initTabContainerStyle
            }

        Just tabs ->
            tabs


{-| Create a composable tab

  - `id` A unique id for the tab
  - `link` The link/menu for the tab
  - `pane` The content part of a tab

-}
tab : List (Attribute msg) -> { id : String, link : Link msg, pane : Pane msg } -> Tab msg
tab attributes { id, link, pane } =
    Tab attributes id link pane


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
