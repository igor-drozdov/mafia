module Leader.Game.Init exposing (..)

import Player
import Html exposing (Html, div, text, button)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Leader.Game.Init.State exposing (State)
import Leader.Game.Current.State as Current
import Leader.Game.Model exposing (..)
import Array exposing (Array)
import List.Extra exposing (find)


type Msg
    = FollowerJoined JE.Value


update : Msg -> State -> ( Model, Cmd Msg )
update msg state =
    case msg of
        FollowerJoined raw ->
            case JD.decodeValue Player.decoder raw of
                Ok player ->
                    let
                        foundModel =
                            find (\p -> p.id == player.id) (Array.toList state.players)
                    in
                        case foundModel of
                            Just _ ->
                                Init state ! []

                            Nothing ->
                                let
                                    newPlayers =
                                        Array.push player state.players
                                in
                                    if Array.length newPlayers == state.total then
                                        Current (Current.State newPlayers) ! []
                                    else
                                        Init { state | players = newPlayers } ! []

                Err error ->
                    Init state ! []


view : State -> Html Msg
view { players, total } =
    div []
        [ div [] [ text "Share the current link with other players" ]
        , div [] [ text ("Waiting for " ++ (toString total) ++ " players to connect") ]
        , div [] (List.map (viewPlayer players) (List.range 0 (total - 1)))
        ]


viewPlayer : Array Player.Model -> Int -> Html Msg
viewPlayer players position =
    case Array.get position players of
        Just player ->
            div []
                [ div [] [ text player.name ]
                , div [] [ text player.id ]
                ]

        Nothing ->
            div []
                [ div [] [ text "Slot for a user" ] ]


decode raw defaultModel =
    case JD.decodeValue Leader.Game.Init.State.decoder raw of
        Ok state ->
            Init state

        Err error ->
            defaultModel
