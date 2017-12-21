module Page.AccountAdmin exposing (..)

-- import Http
-- import View.Lexi as Lexi

import Data.User as User exposing (User)
import Html exposing (Attribute, Html, a, button, div, hr, input, label, option, select, strong, text)
import Html.Attributes exposing (class, classList, disabled, id, placeholder, selected, type_, value)
import Html.Events exposing (onClick, onInput)
import Util exposing ((=>))
import View.Corral as Corral
import View.Lexi as Lexi


-- MODEL


type alias Model =
    { corral : Corral.Corral
    , newEmail : Maybe String
    , confirmPassword : String -- for confirming email change
    , openDialogs : OpenDialogs
    , changingPassword : ChangingPassword
    , currentPassword : Maybe String -- for changing password
    , newPassword : Maybe String
    }


type OpenDialogs
    = NoDialogs
    | ConfirmChangeEmail


type ChangingPassword
    = Changing
    | NotChanging


init : ( Model, Cmd Msg )
init =
    ( { corral = { activeItem = "Account Info" }
      , newEmail = Nothing
      , confirmPassword = ""
      , openDialogs = NoDialogs
      , changingPassword = NotChanging
      , currentPassword = Nothing
      , newPassword = Nothing
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = CorralItemClicked String
    | NewEmail String
    | ConfirmPassword String
    | CancelChangeEmail
    | OpenConfirmChangeEmail
    | SaveNewEmail
    | ChangePassword
    | CancelChangePassword
    | CurrentPassword String
    | NewPassword String
    | SaveNewPassword


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
                , newEmail = Nothing
                , currentPassword = Nothing
                , newPassword = Nothing
                , changingPassword = NotChanging
            }
                ! []

        NewEmail email ->
            { model | newEmail = Just email } ! []

        ConfirmPassword password ->
            { model | confirmPassword = password } ! []

        CancelChangeEmail ->
            { model
                | newEmail = Nothing
                , confirmPassword = ""
                , openDialogs = NoDialogs
            }
                ! []

        OpenConfirmChangeEmail ->
            { model | openDialogs = ConfirmChangeEmail } ! []

        --TODO: send command with confirmPassword to api
        SaveNewEmail ->
            { model
                | newEmail = Nothing
                , confirmPassword = ""
                , openDialogs = NoDialogs
            }
                ! []

        ChangePassword ->
            { model | changingPassword = Changing } ! []

        CancelChangePassword ->
            { model
                | currentPassword = Nothing
                , newPassword = Nothing
                , changingPassword = NotChanging
            }
                ! []

        CurrentPassword password ->
            { model | currentPassword = Just password } ! []

        NewPassword password ->
            { model | newPassword = Just password } ! []

        --TODO: send command to api
        SaveNewPassword ->
            { model
                | currentPassword = Nothing
                , newPassword = Nothing
                , changingPassword = NotChanging
            }
                ! []



-- VIEW


view : Model -> User -> Html Msg
view model user =
    div [ class "account-admin" ]
        [ Corral.view model.corral "Manage Account" CorralItemClicked <|
            [ "Account Info" => viewAccountInfo model user
            , "Support" => viewSupport model user
            , "Billing" => viewBilling model user
            , "Account Plan" => viewAccountPlan model user
            , "Hosting Accounts" => viewHostingAccounts model user
            , "My Team" => viewMyTeams model user
            , "Delete" => viewDelete model user
            ]
        ]



-- ACCOUNT INFO


viewAccountInfo : Model -> User -> Html Msg
viewAccountInfo model user =
    let
        email =
            case model.newEmail of
                Nothing ->
                    user.email

                Just name ->
                    name
    in
    div [ class "account-info" ]
        [ Lexi.passwordDialog
            (model.openDialogs == ConfirmChangeEmail)
            model.confirmPassword
            CancelChangeEmail
            SaveNewEmail
            ConfirmPassword
        , div [ class "section" ]
            [ div [ class "username" ]
                [ label [ class "basic-label" ] [ text "Username" ]
                , input
                    [ type_ "text"
                    , disabled True
                    , placeholder "Username"
                    , value user.username
                    ]
                    []
                ]
            , div [ class "email" ]
                [ label [ class "basic-label" ] [ text "Email" ]
                , input
                    [ type_ "text"
                    , placeholder "Email"
                    , value email
                    , onInput NewEmail
                    ]
                    []
                ]
            ]
        , Lexi.saveSection
            (Just user.email == model.newEmail || model.newEmail == Nothing)
            CancelChangeEmail
            OpenConfirmChangeEmail
        , viewPasswordSection model user
        ]


viewPasswordSection : Model -> User -> Html Msg
viewPasswordSection model user =
    div [ class "password-section" ]
        [ div [ class "section-title" ] [ text "Password" ]
        , case model.changingPassword of
            Changing ->
                viewChangePasswordForm model user

            NotChanging ->
                div [ class "change-password", onClick ChangePassword ]
                    [ text "Change Password" ]
        ]


viewChangePasswordForm : Model -> User -> Html Msg
viewChangePasswordForm model user =
    div []
        [ div [ class "section" ]
            [ div [ class "current-password" ]
                [ label [ class "basic-label" ] [ text "Current Password" ]
                , input
                    [ type_ "password"
                    , placeholder "Current Password"
                    , value <|
                        Maybe.withDefault "" model.currentPassword
                    , onInput CurrentPassword
                    ]
                    []
                ]
            , div [ class "new-password" ]
                [ label [ class "basic-label" ]
                    [ text "New Password" ]
                , input
                    [ type_ "password"
                    , placeholder "New Password"
                    , value <|
                        Maybe.withDefault "" model.newPassword
                    , onInput NewPassword
                    ]
                    []
                ]
            ]
        , Lexi.saveSection
            (model.newPassword == Nothing || model.currentPassword == Nothing)
            CancelChangePassword
            SaveNewPassword
        ]



-- SUPPORT


viewSupport : Model -> User -> Html Msg
viewSupport model user =
    div [] []



-- BILLING


viewBilling : Model -> User -> Html Msg
viewBilling model user =
    div [] []



-- ACCOUNT PLAN


viewAccountPlan : Model -> User -> Html Msg
viewAccountPlan model user =
    div [] []



-- HOSTING ACCOUNTS


viewHostingAccounts : Model -> User -> Html Msg
viewHostingAccounts model user =
    div [] []



-- MY TEAMS


viewMyTeams : Model -> User -> Html Msg
viewMyTeams model user =
    div [] []



-- DELETE


viewDelete : Model -> User -> Html Msg
viewDelete model user =
    div [ class "account-delete" ]
        [ div [ class "warning" ]
            [ strong [] [ text "!" ], text "DANGER ZONE", strong [] [ text "!" ] ]
        , div [ class "subtext" ] [ text "BEWARE! THIS CANNOT BE UNDONE!" ]
        , button [ class "basic-button danger-inverse" ] [ text "Delete Account" ]
        ]
