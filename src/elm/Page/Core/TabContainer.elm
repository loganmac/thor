port module Page.Core.TabContainer exposing (..)

import Dict exposing (Dict)
import Html exposing (Attribute, Html, a, div, li, text, ul)
import Html.Attributes exposing (class, classList, href, id, style)
import Html.Events exposing (onClick)
import Maybe.Extra exposing (isJust)
import Process
import Task
import Time exposing (Time, millisecond)


-- TYPES


{-| A tab is the combination of a link and a pane,
with an identifier to link them together
-}
type alias Tab msg =
    { attributes : List (Attribute msg)
    , id : String
    , link : Link msg
    , pane : Pane msg
    }


{-| A link is the interactive 'tabs' that control the state of the container
-}
type alias Link msg =
    { attributes : List (Html.Attribute msg)
    , children : List (Html.Html msg)
    }


{-| A pane is the inner content of the container, one per tab
-}
type alias Pane msg =
    { attributes : List (Html.Attribute msg)
    , children : List (Html.Html msg)
    }


{-| A utility type to describe a transition msg
-}
type alias TransitionMsg msg =
    Id -> TabId -> msg


type alias Id =
    String


type alias TabId =
    String


type alias Height =
    Int



-- MODEL


type Model
    = Model
        { id : String
        , activeTab : Maybe String
        , fadeInTab : Maybe String
        , fadeOutTab : Maybe String
        , height : Height
        , isAnimating : Bool
        , containers : Dict Id Model
        }


{-| Use this to create the inital state for the container
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
        , containers = Dict.empty
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


{-| Remember to wire these up in the parent subscription function.
It's pretty much the exact same pattern as this library,
but just don't cons on the newTabHeight for non-container parents.
-}
subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    Sub.batch <| newTabHeight NewTabHeight :: List.map mapSub (Dict.toList model.containers)


mapSub : ( String, Model ) -> Sub Msg
mapSub ( id, container ) =
    Sub.map (SubcontainerMsg id) (subscriptions container)



-- UPDATE
-- TODO: add a message for immediate? (no animation)


type Msg
    = FadeOut Id TabId
    | NewTabHeight { id : Id, tabId : TabId, height : Height }
    | FadeIn
    | SubcontainerMsg Id Msg



{--|
  Updating for this component goes like this:

  FadeOut => NewTabHeight => FadeIn
  FadeOut ->
    set the activeTab to nothing
    set the clicked tab to fadingIn
    set the activeTab to fading out
    set isAnimating to true (to debounce)
    clear out the state of any subcontainers
    call out to port to measure the height of the tab that was just clicked.
  NewTabHeight ->
    this is received from a port, the callback after we told JS to measure a tab.
    set the height, then wait for the animation and then send FadeIn
  FadeIn ->
    Set the activeTab to the one that was fading in, and clear the other two states.
    set isAnimating to false, because we aren't debouncing anymore

  note: SubcontainerMsg is for nested containers, we dispatch the subMessages to them
-}


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
                        , containers = Dict.empty
                    }
                , measureTab { id = id, tabId = tabId }
                )

        NewTabHeight { id, height, tabId } ->
            -- here we check if the new tab belongs to this element,
            -- since it is registered for messages through subscriptions
            if id == model.id then
                ( Model { model | height = height }, wait FadeIn )
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

        SubcontainerMsg containerId subMsg ->
            let
                ( updated, cmd ) =
                    update subMsg (get containerId model.containers)
            in
            ( Model
                { model | containers = set updated model.containers }
            , Cmd.map (SubcontainerMsg containerId) cmd
            )



-- VIEW


{-| Call this to create a container, passing in a model, a transition message,
and a list of tab elements
-}
view : Model -> (Id -> TabId -> msg) -> List (Tab msg) -> Html msg
view model toMsg tabs =
    div [ class "tab-container" ]
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
            , ( "active", isJust model.activeTab || isJust model.fadeInTab )
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


{-| Utility function for updating a model in a group (dictionary)
of models
-}
set : Model -> Dict String Model -> Dict String Model
set (Model model) models =
    Dict.insert model.id (Model model) models


{-| Utility function for getting (by id) a model from a
group (dictionary) of models
-}
get : String -> Dict String Model -> Model
get id model =
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


{-| Takes an ID, and wraps the message with an annotated SubContainerMsg,
so that we can dispatch those messages to the correct SubContainer
-}
subMsg : Id -> (a -> b -> Msg) -> a -> b -> Msg
subMsg id msg =
    \x y -> SubcontainerMsg id (msg x y)


{-| helper function to do a command after a certain amount of time
-}
wait : msg -> Cmd msg
wait msg =
    Process.sleep (Time.second * 0.7) |> Task.perform (\_ -> msg)


{-| helper function to sequence another message from inside of an update
-}
send : msg -> Cmd msg
send msg =
    Task.succeed msg
        |> Task.perform identity
