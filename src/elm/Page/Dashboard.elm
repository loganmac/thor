module Page.Dashboard exposing (..)

import Data.User as User exposing (User)
import Html exposing (Html)
import Http
import Page.Dashboard.AccountAdmin as AccountAdmin


-- MODEL


type alias Model =
    { page : Page
    , user : User
    }


type Page
    = Home
    | Download
    | NewApp
    | AccountAdmin AccountAdmin.Model
    | TeamAdmin



-- User.getUser "190e0469-08a5-47b5-a78b-c88221df3067" GetUserResponse
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ userSubscriptions model
        , pageSubscriptions model.page
        ]


userSubscriptions : Model -> Sub Msg
userSubscriptions model =
    -- TODO: User level subscriptions
    Sub.none


pageSubscriptions : Page -> Sub Msg
pageSubscriptions page =
    case page of
        Home ->
            Sub.none

        Download ->
            Sub.none

        NewApp ->
            Sub.none

        AccountAdmin subModel ->
            Sub.none

        TeamAdmin ->
            Sub.none



-- UPDATE


type Msg
    = AccountAdminMsg AccountAdmin.Msg
    | GetUserResponse (Result Http.Error User)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( AccountAdminMsg subMsg, AccountAdmin subModel ) ->
            let
                ( updated, cmd ) =
                    AccountAdmin.update subMsg subModel
            in
            { model | page = AccountAdmin updated } ! [ Cmd.map AccountAdminMsg cmd ]

        ( GetUserResponse (Ok user), _ ) ->
            { model | user = user } ! []

        ( GetUserResponse (Err error), _ ) ->
            model ! []

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            model ! []



-- VIEW


view : Model -> Html Msg
view model =
    Html.div [] [ Html.text "Dashboard not yet implemented!" ]
