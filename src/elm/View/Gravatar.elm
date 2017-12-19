module View.Gravatar exposing (..)

import Gravatar exposing (defaultOptions, url, withSize)
import Html exposing (Html, div, img)
import Html.Attributes exposing (class, src)


type GravatarStyle
    = Round
    | NotRound


gravatar : String -> GravatarStyle -> Int -> Html msg
gravatar email gStyle size =
    let
        roundClass =
            case gStyle of
                Round ->
                    "gravatar round"

                NotRound ->
                    "gravatar"
    in
    div [ class roundClass ]
        [ img [ src <| url (defaultOptions |> withSize (Just size)) email ] []
        ]
