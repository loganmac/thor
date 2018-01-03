module Page.App.Admin exposing (..)

-- import Http

import Data.App as App exposing (App)
import Html exposing (Attribute, Html, a, button, div, hr, input, label, option, select, strong, text)
import Html.Attributes exposing (class, classList, disabled, id, placeholder, selected, type_, value)
import Html.Events exposing (onClick, onInput)
import Util exposing ((=>))
import View.Corral as Corral
import View.Gravatar as Gravatar exposing (gravatar)
import View.Lexi as Lexi


-- MODEL


type alias Model =
    { corral : Corral.Corral
    , newAppName : Maybe String
    , ownership : Ownership
    , newOwner : Maybe String
    , shouldBoxfileUpdate : Maybe Bool
    , settings :
        { shouldBoxfileUpdate : Bool
        }
    }


type Ownership
    = Default
    | Transferring


init : ( Model, Cmd Msg )
init =
    ( { corral = { activeItem = "App Info" }
      , newAppName = Nothing
      , ownership = Default
      , newOwner = Nothing
      , shouldBoxfileUpdate = Nothing
      , settings = { shouldBoxfileUpdate = True }
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = CorralItemClicked String
    | NewAppName String
    | CancelNewAppName
    | StartTransferOwnership
    | SetNewOwner String
    | CancelTransferOwnership
    | SaveTransferOwnership
    | SaveNewAppName
    | ToggleBoxfileUpdate Bool
    | CancelDeploySettings
    | SaveDeploySettings Bool
    | UpdateAgent
    | SyncProvider


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ corral } as model) =
    case msg of
        CorralItemClicked str ->
            let
                updatedCorral =
                    { corral | activeItem = str }
            in
            { model
                | corral = updatedCorral
                , ownership = Default
                , newOwner = Nothing
                , shouldBoxfileUpdate = Nothing
            }
                ! []

        NewAppName name ->
            { model | newAppName = Just name } ! []

        CancelNewAppName ->
            { model | newAppName = Nothing } ! []

        StartTransferOwnership ->
            { model | ownership = Transferring } ! []

        SetNewOwner owner ->
            { model | newOwner = Just owner } ! []

        CancelTransferOwnership ->
            { model | ownership = Default, newOwner = Nothing } ! []

        -- TODO: Make http request once endpoint documentation exists.
        SaveTransferOwnership ->
            { model | ownership = Default, newOwner = Nothing } ! []

        -- TODO: Make http request once endpoint documentation exists.
        SaveNewAppName ->
            { model | newAppName = Nothing } ! []

        -- TODO: Make http request once endpoint documentation exists.
        ToggleBoxfileUpdate bool ->
            { model | shouldBoxfileUpdate = Just bool } ! []

        CancelDeploySettings ->
            { model | shouldBoxfileUpdate = Nothing } ! []

        -- TODO: Make http request once endpoint documentation exists.
        SaveDeploySettings bool ->
            { model
                | shouldBoxfileUpdate = Nothing
                , settings = { shouldBoxfileUpdate = bool }
            }
                ! []

        -- TODO: Make http request once endpoint documentation exists.
        UpdateAgent ->
            model ! []

        -- TODO: Make http request once endpoint documentation exists.
        SyncProvider ->
            model ! []



-- VIEW


view : Model -> App -> Html Msg
view model app =
    div [ class "app-admin" ]
        [ Corral.view model.corral "Manage App" CorralItemClicked <|
            [ "App Info" => viewAppInfo model app
            , "Ownership" => viewOwnership model app
            , "Deploy" => viewDeploy model app
            , "Update Platform" => viewUpdate model app
            , "Security" => viewSecurity model app
            , "Delete" => viewDelete model app
            ]
        ]



-- APP INFO


viewAppInfo : Model -> App -> Html Msg
viewAppInfo model app =
    let
        appName =
            case model.newAppName of
                Nothing ->
                    app.name

                Just name ->
                    name
    in
    div [ class "app-info" ]
        [ label [ class "basic-label" ] [ text "Name" ]
        , input [ type_ "text", placeholder "App Name", value appName, onInput NewAppName ] []
        , Lexi.saveSection
            (model.newAppName == Just app.name || model.newAppName == Nothing)
            CancelNewAppName
            SaveNewAppName
        , label [ class "basic-label" ] [ text "Provider" ]
        , input [ type_ "text", disabled True, placeholder "Provider", value app.providerName ] []
        , label [ class "basic-label" ] [ text "Region" ]
        , input [ type_ "text", disabled True, placeholder "Region", value app.platformRegion ] []
        ]



-- OWNERSHIP


viewOwnership : Model -> App -> Html Msg
viewOwnership model app =
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
            , Lexi.saveSection False CancelTransferOwnership SaveNewAppName
            ]
        ]


viewTransferOptions : Model -> String -> Html msg
viewTransferOptions model name =
    option [ selected <| model.newOwner == Just name ] [ text name ]



-- DEPLOY


viewDeploy : Model -> App -> Html Msg
viewDeploy model app =
    let
        -- TODO: Get settings here from API
        saveButtons shouldUpdate =
            div [ class "save-section" ]
                [ button
                    [ class "basic-button cancel"
                    , onClick CancelDeploySettings
                    ]
                    [ text "Cancel" ]
                , button
                    [ class "basic-button"
                    , onClick <| SaveDeploySettings shouldUpdate
                    ]
                    [ text "Save" ]
                ]

        ( shouldUpdate, saveSection ) =
            case model.shouldBoxfileUpdate of
                Just shouldUpdate ->
                    shouldUpdate => saveButtons shouldUpdate

                Nothing ->
                    model.settings.shouldBoxfileUpdate => div [] []
    in
    div [ class "app-deploy" ]
        [ Lexi.checkbox (ToggleBoxfileUpdate <| not shouldUpdate)
            shouldUpdate
            [ text "On deploy, if a data component's "
            , strong [] [ text "boxfile.yml" ]
            , text " config settings have changed, rebuild it."
            ]
        , saveSection
        ]



-- UPDATE


viewUpdate : Model -> App -> Html Msg
viewUpdate model app =
    div [ class "app-update" ]
        [ div [ class "section" ]
            [ button [ class "basic-button", onClick UpdateAgent ] [ text "Update Agent" ]
            , div [ class "button-text" ]
                [ text "Nanobox installs a small communication agent on each of "
                , text "your servers. Updating cycles through each and ensures "
                , text "they are updated with the latest stable release."
                ]
            ]
        , div [ class "section" ]
            [ button [ class "basic-button", onClick SyncProvider ] [ text "Sync Provider" ]
            , div [ class "button-text" ]
                [ text "On order, Nanobox stores information about each of your "
                , text "servers. This info can get out of sync if the provider "
                , text "changes the IP address after stop/start. Syncing ensures "
                , text "our record is updated and in harmony with your provider."
                ]
            ]
        ]



-- SECURITY


viewSecurity : Model -> App -> Html Msg
viewSecurity model app =
    div [ class "app-security" ]
        [ div [ class "blurb" ]
            [ text "In the vast majority of occasions, the "
            , a [] [ text "Nanobox desktop client" ]
            , text " should be used to remotely access your servers / containers. However, in the "
            , strong [] [ text "very rare" ]
            , text " occasion direct SSH access is needed, use the following information to SSH into your server."
            ]
        , div [ class "section" ]
            [ label [ class "basic-label" ] [ text "Example :" ]
            , div [ class "code-box" ]
                [ div [ class "code" ]
                    [ text <| "ssh root@67.205.154.217 -i /path/to/private_key"
                    ]
                ]
            ]
        , hr [] []
        , div [ class "section" ]
            [ label [ class "basic-label" ] [ text "IP Adddresses :" ]
            , div [ class "code-box" ]
                [ div [ class "code" ]
                    -- TODO: stop hardcoding IP, get data from API
                    (List.map viewIpAddress [ "do.1.1" => "65.144.233.522" ])
                ]
            ]
        , div [ class "section" ]
            [ label [ class "basic-label" ] [ text "Private SSH Key :" ]
            , div [ class "code-box" ]
                [ div [ class "code" ]
                    [ div [] [ text "-----BEGIN RSA PRIVATE KEY-----" ]

                    -- TODO: GET KEY HERE
                    , div [] [ text "MIICXAIBAAKBgQCqGKukO1De7zhZj6+H0qtjTkVxwTCpvKe4eCZ0FPqri0cb2JZfXJ/DgYSF6vUpwmJG8wVQZKjeGcjDOL5UlsuusFncCzWBQ7RKNUSesmQRMSGkVb1/3j+skZ6UtW+5u09lHNsj6tQ51s1SPrCBkedbNf0Tp0GbMJDyR4e9T04ZZwIDAQABAoGAFijko56+qGyN8M0RVyaRAXz++xTqHBLh3tx4VgMtrQ+WEgCjhoTwo23KMBAuJGSYnRmoBZM3lMfTKevIkAidPExvYCdm5dYq3XToLkkLv5L2pIIVOFMDG+KESnAFV7l2c+cnzRMW0+b6f8mR1CJzZuxVLL6Q02fvLi55/mbSYxECQQDeAw6fiIQXGukBI4eMZZt4nscy2o12KyYner3VpoeE+Np2q+Z3pvAMd/aNzQ/W9WaI+NRfcxUJrmfPwIGm63ilAkEAxCL5HQb2bQr4ByorcMWm/hEP2MZzROV73yF41hPsRC9m66KrheO9HPTJuo3/9s5p+sqGxOlFL0NDt4SkosjgGwJAFklyR1uZ/wPJjj611cdBcztlPdqoxssQGnh85BzCj/u3WqBpE2vjvyyvyI5kX6zk7S0ljKtt2jny2+00VsBerQJBAJGC1Mg5Oydo5NwD6BiROrPxGo2bpTbu/fhrT8ebHkTz2eplU9VQQSQzY1oZMVX8i1m5WUTLPz2yLJIBQVdXqhMCQBGoiuSoSjafUhV7i1cEGpb88h5NBYZzWXGZ37sJ5QsW+sJyoNde3xH8vdXhzU7eT82D6X/scw9RZz+/6rCJ4p0=" ]
                    , div [] [ text "-----END RSA PRIVATE KEY----" ]
                    ]
                ]
            ]
        ]


viewIpAddress : ( String, String ) -> Html msg
viewIpAddress ( hostName, ipAddress ) =
    div [ class "ip-address" ]
        [ div [] [ strong [] [ text <| hostName ++ ":" ] ]
        , div [] [ text ipAddress ]
        ]



-- DELETE


viewDelete : Model -> App -> Html Msg
viewDelete model app =
    div [ class "app-delete" ]
        [ div [ class "warning" ]
            [ strong [] [ text "!" ], text "DANGER ZONE", strong [] [ text "!" ] ]
        , div [ class "subtext" ] [ text "BEWARE! THIS CANNOT BE UNDONE!" ]
        , button [ class "basic-button danger-inverse" ] [ text "Delete App" ]
        ]
