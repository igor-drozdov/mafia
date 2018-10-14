module Leader.Finished exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (src, style, class)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Leader.Finished.Model exposing (..)
import Views.Logo exposing (logo)


init : JE.Value -> Result String Model
init raw =
    Result.map Finishing (JD.decodeValue decoder raw)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        _ ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    case model of
        Finishing { state } ->
            case state of
                "innocents" ->
                    div [] [ logo, text "Innocents win" ]

                "mafia" ->
                    div [ class "margin-top" ]
                        [ img [ src "/images/mafia-wins.gif", style [ ( "width", "70%" ) ] ] []
                        ]

                _ ->
                    div [] [ logo, text "Somebody else wins" ]
