module Page.AppDash exposing (..)

import Data.AppDash as AppDash
import Dict exposing (Dict)
import Html exposing (Attribute, Html, a, div, h1, li, text, ul)
import Html.Attributes exposing (class, classList, disabled, href, id, style)
import Html.Events exposing (onClick)
import Port
import Time
import Util
import View.Container as Container


-- MODEL


type alias Model =
    { appDash : AppDash.AppDash
    , containers : Container.Containers
    , isAnimating : Bool
    }



-- here we are initializing the state. In the real app,
-- we will make an api call to fetch the data, then use the returned
-- data to initialize containers


init : ( Model, Cmd msg )
init =
    ( { appDash = AppDash.initialModel
      , containers = Dict.empty
      , isAnimating = False
      }
    , Cmd.none
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Port.newContentHeight NewContentHeight



-- UPDATE


type Msg
    = FadeOut Container.FadeOutMsg
    | NewContentHeight Container.NewContentHeightsMsg
    | FadeIn Container.FadeInMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FadeOut cMsg ->
            ( { model
                | isAnimating = True
                , containers = Container.fadeOut cMsg model.containers
              }
            , Port.measureContent
                { containerId = cMsg.containerId
                , contentId = Container.alreadyActive cMsg.contentId cMsg.oldContentId
                , parentId = cMsg.parentId
                , oldContentId = cMsg.oldContentId
                }
            )

        NewContentHeight cMsg ->
            ( { model
                | containers = Container.newContentHeights cMsg model.containers
              }
            , Util.wait (Time.second * 0.7) <|
                FadeIn { containerId = cMsg.containerId, parentId = cMsg.parentId }
            )

        FadeIn cMsg ->
            ( { model
                | isAnimating = False
                , containers = Container.fadeIn cMsg model.containers
              }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "app-dash" ]
        [ -- view app details
          div [ class "app-dash hosts" ] <|
            List.map (viewHost model) model.appDash.hosts
        , div [ class "app-dash clusters" ] <|
            List.map (viewCluster model) model.appDash.clusters
        ]


viewHost : Model -> AppDash.Host -> Html Msg
viewHost model host =
    let
        parentId =
            ""

        container =
            Container.get host.id parentId model.containers
    in
    div [ class "app-dash host" ]
        [ div [ class "container-title" ] [ h1 [] [ text host.name ] ]
        , containerLinks model container parentId
        , Container.containerView
            [ div [ class "medium-block" ] []
            , div [] <|
                List.map (viewComponent model host.id) host.components
            , div [ class "small-block" ] []
            ]
            container
        ]


viewComponent : Model -> String -> AppDash.Component -> Html Msg
viewComponent model parentId component =
    let
        container =
            Container.get component.id parentId model.containers
    in
    div [ class "app-dash component" ]
        [ div [ class "container-title" ] [ h1 [] [ text component.name ] ]
        , containerLinks model container parentId
        , Container.containerView
            [ div [ class "large-block" ] []
            , div [ class "medium-block" ] []
            , div [ class "small-block" ] []
            ]
            container
        ]


viewCluster : Model -> AppDash.Cluster -> Html Msg
viewCluster model cluster =
    let
        parentId =
            ""

        container =
            Container.get cluster.id parentId model.containers
    in
    div [ class "app-dash cluster" ]
        [ div [ class "container-title" ] [ h1 [] [ text cluster.name ] ]
        , containerLinks model container parentId
        , Container.containerView
            [ div [ class "small-block" ] []
            , div [ class "medium-block" ] []
            , div [ class "large-block" ] []
            ]
            container
        ]


containerLinks : Model -> Container.Container -> Container.ParentId -> Html Msg
containerLinks model container parentId =
    ul [ class "links" ] <|
        List.map (viewLink model container parentId) [ "1", "2", "3" ]


viewLink : Model -> Container.Container -> Container.ContentId -> Container.ParentId -> Html Msg
viewLink model container parentId contentId =
    let
        link =
            "#" ++ container.id ++ contentId

        oldContentId =
            Maybe.withDefault "" container.activeContentId

        click =
            if model.isAnimating then
                disabled True
            else
                onClick <|
                    FadeOut
                        { containerId = container.id
                        , contentId = contentId
                        , oldContentId = oldContentId
                        , parentId = parentId
                        }
    in
    li
        [ class "link", click ]
        [ a [ href <| link ] [ text contentId ] ]
