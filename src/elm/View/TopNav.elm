module View.TopNav exposing (..)

import Html exposing (Attribute, Html, a, div, img, text)
import Html.Attributes exposing (alt, class, src)
import Route as Route exposing (Route)


-- MODEL


type alias LogoPaths r =
    { r
        | logoPath : String
        , homeLogoPath : String
        , supportLogoPath : String
    }



-- VIEW


view : LogoPaths r -> Html msg -> Html msg
view model inner =
    let
        ( homeLink, _ ) =
            Route.linkTo (Route.Authed <| Route.Dash <| Route.Dashboard)
    in
    div [ class "top-nav" ]
        [ div [ class "logo" ]
            [ img [ src model.logoPath ] []
            , a [ class "txt caps", homeLink ] [ text "Nanobox" ]
            ]
        , div [ class "link" ]
            [ img [ src model.homeLogoPath ] []
            , a [ class "txt", homeLink ] [ text "Home" ]
            ]
        , div [ class "link" ]
            [ img [ src model.supportLogoPath ] []
            , a [ class "txt" ] [ text "Support" ]
            ]
        , inner
        ]
