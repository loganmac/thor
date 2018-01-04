module Page.App.Ownership exposing (..)

import Data.App as App exposing (App)
import Html exposing (Html, button, div, label, option, select, strong, text)
import Html.Attributes exposing (class, disabled, selected)
import Html.Events exposing (onClick, onInput)
import View.Gravatar as Gravatar exposing (gravatar)
import View.Lexi as Lexi


-- MODEL


type alias Model =
    { ownership : Ownership
    , newOwner : Maybe String
    }


type Ownership
    = Default
    | Transferring


init : ( Model, Cmd Msg )
init =
    { ownership = Default
    , newOwner = Nothing
    }
        ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


type Msg
    = StartTransferOwnership
    | SetNewOwner String
    | CancelTransferOwnership
    | SaveTransferOwnership


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartTransferOwnership ->
            { model | ownership = Transferring } ! []

        SetNewOwner owner ->
            { model | newOwner = Just owner } ! []

        CancelTransferOwnership ->
            { model | ownership = Default, newOwner = Nothing } ! []

        -- TODO: Make http request once endpoint documentation exists.
        SaveTransferOwnership ->
            { model | ownership = Default, newOwner = Nothing } ! []



-- VIEW


view : Model -> App -> Html Msg
view model app =
    let
        inner =
            case model.ownership of
                Default ->
                    viewCurrentOwnership model app

                Transferring ->
                    viewTransferOwnership model app
    in
    div [ class "app-ownership" ] [ inner ]


viewCurrentOwnership : Model -> App -> Html Msg
viewCurrentOwnership model app =
    div [ class "view-ownership" ]
        -- TODO: actually get data from API here
        [ div [ class "profile-img" ]
            [ gravatar "contact@parslee.com" Gravatar.Round 75
            ]
        , div [ class "" ] [ text "johnny_appleseed" ]
        , button [ onClick StartTransferOwnership, class "basic-button" ]
            [ text "Transfer Ownership" ]
        ]


viewTransferOwnership : Model -> App -> Html Msg
viewTransferOwnership model app =
    let
        selectedOwner =
            Maybe.withDefault "new-owner" model.newOwner
    in
    div [ class "change-ownership" ]
        [ div [ class "section txt" ]
            [ div [ class "important" ] [ text "Important!" ]
            , div []
                [ text "Transferring will change this app's subdomain from: "
                , div []
                    -- TODO: actually get options from API here
                    [ strong [] [ text "forum.nanoapp.io" ]
                    , text " to "
                    , strong [] [ text <| selectedOwner ++ "-forum.nanoapp.io" ]
                    ]
                ]
            ]
        , div [ class "section" ]
            [ label [ class "basic-label" ] [ text "Transfer to :" ]
            , select [ onInput SetNewOwner ] <|
                -- TODO: actually get the options from API here
                [ option [ disabled True, selected True ] [ text "Select a transfer target" ] ]
                    ++ List.map (viewTransferOptions model) [ "my-team-mate", "my-team" ]
            , Lexi.saveSection False CancelTransferOwnership SaveTransferOwnership
            ]
        ]


viewTransferOptions : Model -> String -> Html msg
viewTransferOptions model name =
    option [ selected <| model.newOwner == Just name ] [ text name ]
