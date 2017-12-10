port module Page.Core.TabContainer exposing (..)

import Dict exposing (Dict)
import Html exposing (Attribute, Html, a, div, li, text, ul)
import Html.Attributes exposing (class, classList, href, id, style)
import Html.Events exposing (onClick)
import Maybe.Extra
import Process
import Task
import Time exposing (Time, millisecond)


-- TYPES
-- these first aliases are gross I know, FIXME: later


type alias Id =
    String


type alias TabId =
    String


type alias Height =
    Int


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


type alias ToMsg msg =
    Id -> TabId -> msg



-- MODEL


type Model
    = Model
        { id : String
        , activeTab : Maybe String
        , fadeInTab : Maybe String
        , fadeOutTab : Maybe String
        , height : Height
        , isAnimating : Bool
        , subContainers : Dict Id Model
        }


{-| Use this function to create the inital state for the tabs control
-}
init : String -> ( String, Model )
init id =
    ( id, initialModel id )


initialModel : String -> Model
initialModel id =
    Model
        { id = id
        , activeTab = Nothing
        , fadeInTab = Nothing
        , fadeOutTab = Nothing
        , height = 0
        , isAnimating = False
        , subContainers = Dict.empty
        }



-- PORTS


{-| measureTab the change animation of a flexWrapper
send a tabContainerId, and a tabId
-}
port measureTab : { id : Id, tabId : TabId } -> Cmd msg


{-| sends back the new height of a tab.
sends back a tabContainerId, tabId, and a height
-}
port newTabHeight : ({ id : Id, tabId : TabId, height : Height } -> msg) -> Sub msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    newTabHeight NewTabHeight



-- UPDATE
-- TODO: add a message for immediate? (no animation)


type Msg
    = FadeOut Id TabId
    | NewTabHeight { id : Id, tabId : TabId, height : Height }
    | FadeIn
    | SubContainerMsg Id Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    case msg of
        FadeOut id tabId ->
            if model.isAnimating then
                ( Model model, Cmd.none )
            else
                ( Model
                    { model
                        | activeTab = Nothing
                        , fadeInTab = Just tabId
                        , fadeOutTab = model.activeTab
                        , isAnimating = True
                    }
                , measureTab { id = id, tabId = tabId }
                )

        NewTabHeight { id, height, tabId } ->
            -- here we check if the new tab belongs to this element,
            -- since it is registered for messages through subscriptions
            if id == model.id then
                ( Model { model | height = height }, after (Time.second * 1.5) FadeIn )
                -- ( { model | height = height }, send FadeIn )
            else
                ( Model model, Cmd.none )

        FadeIn ->
            ( Model
                { model
                    | activeTab = model.fadeInTab
                    , fadeInTab = Nothing
                    , fadeOutTab = Nothing
                    , isAnimating = False
                }
            , Cmd.none
            )

        SubContainerMsg containerId subMsg ->
            let
                ( updatedTabContainer, tabContainerCmd ) =
                    update subMsg <| findTabContainer containerId model.subContainers
            in
            ( Model
                { model
                    | subContainers =
                        updateTabContainer updatedTabContainer model.subContainers
                }
            , Cmd.map (SubContainerMsg containerId) tabContainerCmd
            )



-- VIEW


view : Model -> (Id -> TabId -> msg) -> List (Tab msg) -> Html msg
view model toMsg tabs =
    div []
        [ ul [ class "tab-links" ] (List.map (viewLink model toMsg) tabs)
        , viewPaneContainer model tabs
        ]


viewLink : Model -> (Id -> TabId -> msg) -> Tab msg -> Html msg
viewLink (Model model) toMsg currentTab =
    let
        maybe check =
            Maybe.withDefault "" (check model)

        isActive =
            currentTab.id == maybe .activeTab || currentTab.id == maybe .fadeInTab
    in
    li
        [ classList [ ( "tab-link", True ), ( "active", isActive ) ]
        , onClick <| toMsg model.id currentTab.id
        ]
        [ a
            ([ href <| "#" ++ currentTab.id ] ++ currentTab.link.attributes)
            currentTab.link.children
        ]


viewPaneContainer : Model -> List (Tab msg) -> Html msg
viewPaneContainer (Model model) tabs =
    div
        [ id model.id
        , classList
            [ ( "tab-panes", True )
            , ( "active", Maybe.Extra.isJust model.activeTab || Maybe.Extra.isJust model.fadeInTab )
            ]
        , style [ ( "height", toString model.height ++ "px" ) ]
        ]
        (List.map (viewPane (Model model)) tabs)


viewPane : Model -> Tab msg -> Html msg
viewPane (Model model) currentTab =
    let
        is check =
            currentTab.id == Maybe.withDefault "" (check model)

        displayClass =
            if is .activeTab then
                " active"
            else if is .fadeInTab then
                " fade-in"
            else if is .fadeOutTab then
                " fade-out"
            else
                " hidden"
    in
    div
        ([ id (model.id ++ "-" ++ currentTab.id) ]
            ++ [ class ("tab-pane" ++ displayClass) ]
            ++ currentTab.pane.attributes
        )
        currentTab.pane.children


updateTabContainer : Model -> Dict String Model -> Dict String Model
updateTabContainer (Model model) models =
    Dict.insert model.id (Model model) models


findTabContainer : String -> Dict String Model -> Model
findTabContainer id model =
    case Dict.get id model of
        Nothing ->
            initialModel id

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


{-| helper function to do a command after a certain amount of time
-}
after : Time.Time -> msg -> Cmd msg
after time msg =
    Process.sleep time |> Task.perform (\_ -> msg)


{-| helper function to sequence another message from inside of an update
-}
send : msg -> Cmd msg
send msg =
    Task.succeed msg
        |> Task.perform identity
