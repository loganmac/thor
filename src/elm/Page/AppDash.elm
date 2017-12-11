module Page.AppDash exposing (..)

import Dict exposing (Dict)
import Html exposing (Attribute, Html, a, div, li, text, ul)
import Html.Attributes exposing (class, classList, disabled, href, id, style)
import Html.Events exposing (onClick)
import Port
import Time
import Util
import View.Container as Container


-- MODEL


type alias Model =
    { containers : Container.Containers
    , isAnimating : Bool
    }



-- here we are initializing the state. In the real app,
-- we will make an api call to fetch the data, then use the returned
-- data to initialize containers


init : ( Model, Cmd msg )
init =
    ( { containers = Dict.fromList demoContainers, isAnimating = False }, Cmd.none )


demoContainers : List ( String, Container.Container )
demoContainers =
    [ Container.container "container1"
    , Container.container "container2"
    ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Port.newContentHeight NewContentHeight



-- UPDATE


type Msg
    = FadeOut String String
    | NewContentHeight { containerId : String, contentId : String, newHeight : Float }
    | FadeIn String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FadeOut containerId contentId ->
            ( { model
                | containers = Container.fadeOut containerId contentId model.containers
                , isAnimating = True
              }
            , Port.measureContent { containerId = containerId, contentId = contentId }
            )

        NewContentHeight { containerId, newHeight, contentId } ->
            ( { model
                | containers =
                    Container.newContentHeight
                        containerId
                        contentId
                        newHeight
                        model.containers
              }
            , Util.wait (Time.second * 1) (FadeIn containerId)
            )

        FadeIn containerId ->
            ( { model | containers = Container.fadeIn containerId model.containers, isAnimating = False }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    let
        containers =
            Dict.values model.containers

        contents =
            []
    in
    div [ class "app-dash" ]
        []



-- containerLinks : Model -> String -> Container.Container -> Html Msg
-- containerLinks model containerId =
--     ul [ class "links" ] (List.map (viewLink model containerId) contentId)


viewLink : Model -> String -> String -> Html Msg
viewLink model containerId contentId =
    let
        link =
            "#" ++ containerId ++ contentId

        action =
            if model.isAnimating then
                disabled True
            else
                onClick <| FadeOut containerId contentId
    in
    li
        [ class "link", action ]
        [ a [ href <| link ] [ text <| "Change " ++ link ] ]
