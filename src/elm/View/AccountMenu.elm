module View.AccountMenu exposing (..)

import Gravatar exposing (defaultOptions, url, withSize)
import Html exposing (Attribute, Html, a, div, img, text)
import Html.Attributes exposing (alt, class, href, id, src)


type GravatarStyle
    = Round
    | NotRound


view : Html msg
view =
    div [ class "account-menu" ]
        [ div [ class "profile-img" ]
            [ div [ class "profile" ]
                [ gravatar "contact@parslee.com" Round 36
                ]
            , div [ class "circ-arrow" ] []
            ]

        -- , div [ class "account-sub-menu" ]
        --     [ div [ class "teams" ] [] -- TODO: for team in teams... teamItem
        --     , div [ class "account-admin" ]
        --         [ div [ class "top" ]
        --             [ div [ class "image-box" ]
        --                 [ div [ class "profile" ]
        --                     [ gravatar "contact@parslee.com" Round 36 ]
        --                 ]
        --             , div [ class "actions" ]
        --                 [ a [ href "ADMIN-PATH" ] [ text "Admin" ]
        --                 , a [ id "logout" ] [ text "Logout" ]
        --                 ]
        --             ]
        --         , a [ class "new-team", href "ASDF" ] [ text "Create a new team" ]
        --         ]
        --     ]
        ]


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
