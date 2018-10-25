module Views.Logo exposing (animatedCircuit, animatedLogo, logo)

import Html exposing (Html, div, img)
import Html.Attributes exposing (class, src)


logo : Html msg
logo =
    div [ class "logo" ]
        [ img [ src "/images/logo.svg" ] []
        ]


animatedLogo : Html msg
animatedLogo =
    div [ class "logo" ]
        [ img [ src "/images/animated-logo.svg" ] []
        ]


animatedCircuit : Html msg -> Html msg
animatedCircuit content =
    div [ class "logo" ]
        [ img [ src "/images/animated-circuit.svg" ] []
        , content
        ]
