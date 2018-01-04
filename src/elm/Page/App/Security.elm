module Page.App.Security exposing (..)

import Data.App exposing (App)
import Html exposing (Html, a, div, hr, label, strong, text)
import Html.Attributes exposing (class)
import Util exposing ((=>))


-- MODEL


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    {} ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []



-- VIEW


view : Model -> App -> Html Msg
view model app =
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
