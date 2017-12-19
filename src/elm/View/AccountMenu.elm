module View.AccountMenu exposing (..)

import Html exposing (Attribute, Html, a, div, img, text)
import Html.Attributes exposing (alt, class, href, id, src)
import View.Gravatar as Gravatar exposing (gravatar)


view : Html msg
view =
    div [ class "account-menu" ]
        [ div [ class "profile-img" ]
            [ div [ class "profile" ]
                [ gravatar "contact@parslee.com" Gravatar.Round 36
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
