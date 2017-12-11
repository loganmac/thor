module View.Container exposing (..)

import Dict exposing (Dict)
import Html exposing (Attribute, Html, a, div, li, text, ul)
import Html.Attributes exposing (class, classList, disabled, href, id, style)
import Maybe.Extra exposing (isJust)


type alias Containers =
    Dict String Container


{-| Container is the element that flexes to fit its inner contents
-}
type alias Container =
    { id : String
    , activeContentId : Maybe String
    , fadeInContentId : Maybe String
    , fadeOutContentId : Maybe String
    , height : Float
    }


{-| Use this to create the inital state for the container
-}
init : String -> Container
init id =
    { id = id
    , activeContentId = Nothing
    , fadeInContentId = Nothing
    , fadeOutContentId = Nothing
    , height = 0
    }


containerView : List (Html msg) -> Container -> Html msg
containerView contents container =
    div
        [ id container.id
        , classList
            [ ( "container", True )
            , ( "active", isJust container.activeContentId || isJust container.fadeInContentId )
            ]
        , style [ ( "height", toString container.height ++ "px" ) ]
        ]
        (List.indexedMap (contentView container) contents)


contentView : Container -> Int -> Html msg -> Html msg
contentView container index content =
    let
        contentId =
            "content-" ++ toString index

        is check =
            contentId == Maybe.withDefault "" (check container)

        displayClass =
            if is .activeContentId then
                " active"
            else if is .fadeInContentId then
                " fade-in"
            else if is .fadeOutContentId then
                " fade-out"
            else
                " hidden"
    in
    div
        ([ id (container.id ++ contentId) ]
            ++ [ class ("content" ++ displayClass) ]
        )
        [ content ]


{-| Create a container with default properties
-}
container : String -> ( String, Container )
container id =
    ( id, init id )


{-| Utility for updating a container in a group (dictionary)
of container
-}
set : Container -> Dict String Container -> Dict String Container
set container containers =
    Dict.insert container.id container containers


{-| Utility for getting (by id) a model from a
group (dictionary) of models
-}
get : String -> Dict String Container -> Container
get id model =
    case Dict.get id model of
        Nothing ->
            init id

        Just container ->
            container



{--|
  UPDATING
  Updating for this component goes like this:

  FadeOut => NewContentHeight => FadeIn
  FadeOut ->
    set the activeContentId to nothing
    set the clicked contentId to fadingIn
    set the activeContentId to fading out
    set isAnimating to true (to debounce)
    clear out the state of any subcontainers TODO: this
    call out to port to measure the height of the contentId that was just clicked.
  NewContentHeight ->
    this is received from a port, the callback after we told JS to measure content.
    set the height, then wait for the animation and then send FadeIn
  FadeIn containerId ->
    Set the activeContentId to the one that was fading in, and clear the other two states.
    set isAnimating to false, because we aren't debouncing anymore

-}


{-| updates the state of a container to fade it out
-}
fadeOut : String -> String -> Dict String Container -> Dict String Container
fadeOut containerId contentId containers =
    let
        oldContainer =
            get containerId containers
    in
    set
        { oldContainer
            | activeContentId = Nothing
            , fadeInContentId = Just contentId
            , fadeOutContentId = oldContainer.activeContentId
        }
        containers


{-| updates the state of a container with a new height
-}
newContentHeight : String -> String -> Float -> Dict String Container -> Dict String Container
newContentHeight containerId contentId newHeight containers =
    let
        oldContainer =
            get containerId containers
    in
    set { oldContainer | height = newHeight } containers


{-| updates the state of a container to fade it i n
-}
fadeIn : String -> Dict String Container -> Dict String Container
fadeIn containerId containers =
    let
        oldContainer =
            get containerId containers
    in
    set
        { oldContainer
            | activeContentId = oldContainer.fadeInContentId
            , fadeInContentId = Nothing
            , fadeOutContentId = Nothing
        }
        containers
