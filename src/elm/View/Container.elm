module View.Container exposing (..)

import Dict exposing (Dict)
import Html exposing (Attribute, Html, a, div, text)
import Html.Attributes exposing (class, classList, disabled, href, id, style)
import Html.Events exposing (onClick)
import Util exposing ((=>))


{-| Container is the element that flexes to fit its inner contents
-}
type alias Container =
    { id : Id
    , parentId : ParentId
    , activeContentId : Maybe ContentId
    , fadeInContentId : Maybe ContentId
    , fadeOutContentId : Maybe ContentId
    , height : Float
    }



-- TYPE ALIASES (to make signatures easier to understand)


type alias FadeOutMsg =
    { containerId : Id
    , contentId : ContentId
    , oldContentId : ContentId
    , parentId : ParentId
    }


type alias NewContentHeightsMsg =
    { containerId : Id
    , contentId : ContentId
    , newHeight : Height
    , oldHeight : Height
    , parentId : ParentId
    }


type alias FadeInMsg =
    { containerId : Id
    , contentId : ContentId
    , newHeight : Height
    , oldHeight : Height
    , parentId : ParentId
    }


type alias Containers =
    Dict String Container


type alias Id =
    String


type alias ContentId =
    String


type alias ParentId =
    String


type alias Height =
    Float


{-| Use this to create the inital state for the container
-}
init : Id -> ParentId -> Container
init id parentId =
    { id = id
    , parentId = parentId
    , activeContentId = Nothing
    , fadeInContentId = Nothing
    , fadeOutContentId = Nothing
    , height = 0
    }



-- UPDATE
{--|
  UPDATING
  Updating for this component goes like this:

  FadeOut => NewContentHeight => FadeIn

  The parent component needs to do the following for this to work properly:

  FadeOut ->
    set a flag/bool to debounce messages (isAnimating = True) in parent state
    if isAnimating, then don't do anything (debounce)
    call out to port to measure the height of the contentId that was just clicked.

  NewContentHeight ->
    this is received from a port, the callback after we told JS to measure content.
    send the message to set the height, then wait for the animation, then send FadeIn

  FadeIn containerId ->
    set isAnimating to false, because we aren't debouncing anymore
    send the message to fadeIn content
-}


{-| updates the state of a container to fade it out
-}
fadeOut : Containers -> FadeOutMsg -> Containers
fadeOut containers { containerId, contentId, parentId } =
    let
        currentContainer =
            get containerId parentId containers

        fadeInId =
            -- if container is already active, let it fade out
            if Just contentId == currentContainer.activeContentId then
                Nothing
            else
                Just contentId
    in
    -- reset subcontainers and update the animating container
    set
        { currentContainer
            | activeContentId = Nothing
            , fadeInContentId = fadeInId
            , fadeOutContentId = currentContainer.activeContentId
        }
    <|
        resetSubcontainers containerId containers


{-| updates the state of a container with a new height
, and reduces the size of the parentContainer with the oldHeight
-}
newContentHeights : Containers -> NewContentHeightsMsg -> Containers
newContentHeights containers { containerId, parentId, newHeight, oldHeight } =
    let
        currentContainer =
            get containerId parentId containers

        parentContainer =
            get parentId "" containers

        parentHeight =
            newHeight + parentContainer.height - oldHeight
    in
    containers
        |> set { currentContainer | height = newHeight }
        |> set { parentContainer | height = parentHeight }


{-| updates the state of a container to fade it in
-}
fadeIn : Containers -> FadeInMsg -> Containers
fadeIn containers { containerId, parentId } =
    let
        currentContainer =
            get containerId parentId containers
    in
    set
        { currentContainer
            | activeContentId = currentContainer.fadeInContentId
            , fadeInContentId = Nothing
            , fadeOutContentId = Nothing
        }
        containers



-- VIEW


view : List (Html msg) -> Container -> Html msg
view contents container =
    div
        [ id container.id
        , class "container"
        , style [ ( "height", toString container.height ++ "px" ) ]
        ]
        (List.indexedMap (viewContent container) contents)


viewContent : Container -> Int -> Html msg -> Html msg
viewContent container index content =
    let
        contentId =
            toString (index + 1)

        is check =
            contentId == Maybe.withDefault "" (check container)
    in
    div
        [ id (container.id ++ "-" ++ contentId)
        , classList
            [ "container-content" => True
            , "active" => is .activeContentId
            , "fade-in" => is .fadeInContentId
            , "fade-out" => is .fadeOutContentId
            ]
        ]
        [ content ]


viewLinks : (FadeOutMsg -> msg) -> Container -> ParentId -> List a -> Html msg
viewLinks msg container parentId contents =
    div [ class "container-links" ] <|
        List.indexedMap (viewLink msg container parentId) contents


viewLink : (FadeOutMsg -> msg) -> Container -> ContentId -> Int -> a -> Html msg
viewLink msg container parentId contentIdNum _ =
    let
        currentContentId =
            toString <| contentIdNum + 1

        oldContentId =
            Maybe.withDefault "" container.activeContentId

        contentId =
            -- if the contentId is already active, use empty string.
            -- this gives us the collapse behavior
            if container.activeContentId == Just currentContentId then
                ""
            else
                currentContentId

        action =
            onClick <|
                msg <|
                    FadeOutMsg container.id contentId oldContentId parentId
    in
    div [ class "container-link", action ] [ text currentContentId ]



-- UTILITIES


{-| Utility for updating a container in a group (dictionary)
of container
-}
set : Container -> Containers -> Containers
set container containers =
    Dict.insert container.id container containers


{-| Utility for getting (by id) a model from a
group (dictionary) of models
-}
get : Id -> ParentId -> Containers -> Container
get id parentId model =
    case Dict.get id model of
        Nothing ->
            init id parentId

        Just container ->
            container


{-| utility to update subcontainers
-}
resetSubcontainers : Id -> Containers -> Containers
resetSubcontainers id containers =
    let
        reset _ container =
            if container.parentId == id then
                init container.id id
            else
                container
    in
    Dict.map reset containers
