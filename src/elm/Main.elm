module Main exposing (..)

-- import Html.Events exposing (onClick)

import Html exposing (Html, br, div, h1, h2, p, text)
import Html.Attributes exposing (class, id, style)
import Page.AppAdmin as AppAdmin
import Page.Core.ClobberBox as ClobberBox
import Page.Core.TopNav as TopNav


-- TYPES


type Page
    = Blank
    | NotFound
    | Dashboard
    | AppDash
    | AppLogs
    | AppHistory
    | AppNetwork
    | AppConfig
    | AppAdmin
    | AccountAdmin
    | TeamAdmin


type PageState
    = Loaded Page
    | TransitioningFrom Page



-- MODEL


type alias Model =
    { appAdmin : AppAdmin.Model
    , accountMenuOpen : Bool
    , clobberBox : ClobberBox.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        ( appAdmininit, appAdminCmd ) =
            AppAdmin.init
    in
    ( { appAdmin = appAdmininit
      , accountMenuOpen = False
      , clobberBox = ClobberBox.init
      }
    , Cmd.batch [ Cmd.map AppAdminMsg appAdminCmd ]
    )



-- UPDATE


type Msg
    = AppAdminMsg AppAdmin.Msg
    | ClickOutside


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AppAdminMsg subMsg ->
            let
                ( updatedAppAdmin, appAdminCmd ) =
                    AppAdmin.update subMsg model.appAdmin
            in
            ( { model | appAdmin = updatedAppAdmin }, Cmd.map AppAdminMsg appAdminCmd )

        ClickOutside ->
            ( { model | accountMenuOpen = False }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "main" ]
        [ TopNav.view

        --
        -- -- Clobber box below
        -- , div
        --     [ class "layout", id "dashbaord-layout" ]
        --     [ div [ class "layout-header" ] []
        --     , div [ class "layout-container", id "apps-dash" ]
        --         [ div [ class "columns col_left eight" ]
        --             [ div [ class "row", id "service-index" ]
        --                 [ h2 [] [ text "Service-specific Server Names" ]
        --                 , div [ id "valkrie" ]
        --                     [ div [ class "boxes" ]
        --                         [ ClobberBox.view model.clobberBox (\_ -> ClickOutside) (text "")
        --                         ]
        --                     ]
        --                 ]
        --             ]
        --         ]
        --     ]
        , Html.map AppAdminMsg (AppAdmin.view model.appAdmin)
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }



-- BACKDROP
-- div
--     [ class "backdrop"
--     , style
--         [ ( "position", "relative" )
--         , ( "top", "0" )
--         , ( "z-index", "1" )
--         , ( "width", "100%" )
--         , ( "height", "100%" )
--         ]
--     , onClick ClickOutside
--     ]
--     [ ]
