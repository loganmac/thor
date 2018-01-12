module Page.NewApp exposing (..)

import Data.App as App
import Data.Hosting as Hosting
import Html exposing (Html, div)
import Html.Attributes exposing (class, id)
import Port
import Route
import Util


-- MODEL


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    {} ! [ Util.wait 0.5 LoadNewApp ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


type Msg
    = LoadNewApp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadNewApp ->
            let
                ( newAppRoute, _ ) =
                    Route.routeToLink Route.newApp
            in
            model
                ! [ Port.newApp
                        { node = "#newApp"
                        , route = newAppRoute
                        , newAppUrl = App.newAppUrl
                        , validateAppUrl = App.validateUrl
                        , providersMetaUrl = Hosting.providersMetaUrl
                        , createProviderAccountUrl = Hosting.providerAccountsUrl
                        , verifyProviderAccountUrl = Hosting.verifyProviderAccountsUrl
                        , providersWithAccounts = [] -- TODO: doesn't exist yet
                        , officialProviders = [] -- TODO: doesn't exist yet
                        , customProviders = [] -- TODO: doesn't exist yet
                        }
                  ]



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "new-app", id "newApp" ] []
