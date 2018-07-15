module Leader.Game.Init exposing (..)

import Player
import Html exposing (Html, div, text, button)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Leader.Game.Init.State exposing (State)
import Leader.Game.Model exposing (..)


init : List Player.Model -> Model
init players =
    Init (State players)


type Msg
    = Play
    | FollowerJoined JE.Value


update : Msg -> State -> ( Model, Cmd Msg )
update msg state =
    case msg of
        Play ->
            Current state ! []

        FollowerJoined raw ->
            case JD.decodeValue Player.decoder raw of
                Ok player ->
                    let
                        foundModels =
                            List.filter (\p -> p.id == player.id) state.players
                    in
                        case List.head foundModels of
                            Just _ ->
                                Init state ! []

                            Nothing ->
                                Init { state | players = player :: state.players } ! []

                Err error ->
                    Init state ! []


view : State -> Html Msg
view { players } =
    div []
        [ div [] [ text "Share the current link with other players" ]
        , div [] [ text "Waiting for other players to connect" ]
        , div [] (List.map viewPlayer players)
        ]


viewPlayer : Player.Model -> Html Msg
viewPlayer player =
    div []
        [ div [] [ text player.name ]
        , div [] [ text player.id ]
        ]
