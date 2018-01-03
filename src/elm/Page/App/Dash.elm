module Page.App.Dash exposing (..)

import Data.AppDash as AppDash exposing (AppDash)
import Dict exposing (Dict)
import Html exposing (Attribute, Html, div, h1, text)
import Html.Attributes exposing (class, id)
import Port
import Util
import View.Container as Container


-- MODEL


type alias Model =
    { appDash : AppDash
    , containers : Container.Containers
    , isAnimating : Bool
    }


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
    Port.newContentHeight NewContentHeights



-- UPDATE


type Msg
    = FadeOut Container.FadeOutMsg
    | NewContentHeights Container.NewContentHeightsMsg
    | FadeIn Container.FadeInMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FadeOut ({ containerId, contentId, oldContentId, parentId } as subMsg) ->
            if model.isAnimating then
                model ! []
            else
                { model
                    | isAnimating = True
                    , containers = Container.fadeOut model.containers subMsg
                }
                    ! [ Port.measureContent subMsg ]

        NewContentHeights ({ containerId, parentId } as subMsg) ->
            { model | containers = Container.newContentHeights model.containers subMsg }
                ! [ Util.wait 0.7 <| FadeIn subMsg ]

        FadeIn ({ containerId, contentId } as subMsg) ->
            { model
                | isAnimating = False
                , containers = Container.fadeIn model.containers subMsg
            }
                ! []



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
        container =
            Container.get host.id "" model.containers

        contents =
            [ div [ class "medium-block" ] []
            , div [] <| List.map (viewComponent model host.id) host.components
            , div [ class "small-block" ] []
            ]
    in
    div [ class "app-dash host" ]
        [ div [ class "container-title" ] [ h1 [] [ text host.name ] ]
        , Container.viewLinks FadeOut container "" contents
        , Container.view contents container
        ]


viewComponent : Model -> String -> AppDash.Component -> Html Msg
viewComponent model parentId component =
    let
        container =
            Container.get component.id parentId model.containers

        contents =
            [ div [ class "large-block" ] []
            , div [ class "medium-block" ] []
            , div [ class "small-block" ] []
            ]
    in
    div [ class "app-dash component" ]
        [ div [ class "container-title" ] [ h1 [] [ text component.name ] ]
        , Container.viewLinks FadeOut container parentId contents
        , Container.view contents container
        ]


viewCluster : Model -> AppDash.Cluster -> Html Msg
viewCluster model cluster =
    let
        container =
            Container.get cluster.id "" model.containers

        contents =
            [ div [ class "small-block" ] []
            , div [ class "medium-block" ] []
            , div [ class "large-block" ] []
            ]
    in
    div [ class "app-dash cluster" ]
        [ div [ class "container-title" ] [ h1 [] [ text cluster.name ] ]
        , Container.viewLinks FadeOut container "" contents
        , Container.view contents container
        ]
