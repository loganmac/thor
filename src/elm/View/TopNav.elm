module View.TopNav exposing (..)

import Html exposing (Attribute, Html, div, img, text)
import Html.Attributes exposing (alt, class, src)


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
    div [ class "top-nav" ]
        [ div [ class "logo" ]
            [ img [ src model.logoPath ] []
            , div [ class "txt caps" ] [ text "Nanobox" ]
            ]
        , div [ class "link" ]
            [ img [ src model.homeLogoPath ] []
            , div [ class "txt" ] [ text "Home" ]
            ]
        , div [ class "link" ]
            [ img [ src model.supportLogoPath ] []
            , div [ class "txt" ] [ text "Support" ]
            ]
        , inner
        ]
