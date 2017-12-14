module View.Container exposing (..)

import Dict exposing (Dict)
import Html exposing (Attribute, Html, a, div, li, text, ul)
import Html.Attributes exposing (class, classList, disabled, href, id, style)
import Maybe.Extra exposing (isJust)


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
            toString (index + 1)

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
        ([ id (container.id ++ "-" ++ contentId) ]
            ++ [ class ("container-content" ++ displayClass) ]
        )
        [ content ]


{-| Utility to determine whether the content is already
the active content of the container
-}
alreadyActive : ContentId -> ContentId -> ContentId
alreadyActive contentId activeContentId =
    if contentId == activeContentId then
        ""
    else
        contentId


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


{-| Utility for getting any subcontainers
-}
getSubcontainers : Id -> Containers -> Containers
getSubcontainers id containers =
    Dict.filter (\k v -> v.parentId == id) containers


{-| utility to update subcontainers
-}
resetSubcontainers : Id -> Containers -> Containers
resetSubcontainers id containers =
    Dict.map
        (\k v ->
            if v.parentId == id then
                init v.id id
            else
                v
        )
        containers



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
fadeOut : FadeOutMsg -> Containers -> Containers
fadeOut { containerId, contentId, parentId } containers =
    let
        oldContainer =
            get containerId parentId containers

        updateContainer =
            if Just contentId == oldContainer.activeContentId then
                set
                    { oldContainer
                        | activeContentId = Nothing
                        , fadeInContentId = Nothing
                        , fadeOutContentId = oldContainer.activeContentId
                    }
            else
                set
                    { oldContainer
                        | activeContentId = Nothing
                        , fadeInContentId = Just contentId
                        , fadeOutContentId = oldContainer.activeContentId
                    }
    in
    resetSubcontainers containerId containers
        |> updateContainer


{-| updates the state of a container with a new height
, and reduces the size of the parentContainer with the oldHeight
-}
newContentHeights : NewContentHeightsMsg -> Containers -> Containers
newContentHeights msg containers =
    let
        oldContainer =
            get msg.containerId msg.parentId containers

        parentContainer =
            get msg.parentId "" containers

        parentHeight =
            msg.newHeight + parentContainer.height - msg.oldHeight
    in
    set { parentContainer | height = parentHeight } <|
        set { oldContainer | height = msg.newHeight } containers


{-| updates the state of a container to fade it in
-}
fadeIn : FadeInMsg -> Containers -> Containers
fadeIn msg containers =
    let
        oldContainer =
            get msg.containerId msg.parentId containers
    in
    set
        { oldContainer
            | activeContentId = oldContainer.fadeInContentId
            , fadeInContentId = Nothing
            , fadeOutContentId = Nothing
        }
        containers
