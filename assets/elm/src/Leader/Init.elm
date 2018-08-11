module Leader.Init exposing (..)

import Player
import Html exposing (Html, div, text, button)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Phoenix.Channel
import Phoenix.Socket
import Leader.Init.State exposing (State)
import Leader.Current.State as Current
import Leader exposing (Model)
import Array exposing (Array)
import List.Extra exposing (find)


type Msg
    = FollowerJoined JE.Value
    | LoadGame JE.Value


init : String -> Model
init gameId =
    let
        channelName =
            ("rooms:leader:init" ++ gameId)

        channel =
            Phoenix.Channel.init channelName
                |> Phoenix.Channel.onJoin LoadGame

        initPhxSocket =
            Phoenix.Socket.init socketServer
                |> Phoenix.Socket.withDebug

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel initPhxSocket

        phxSocketWithListener : Phoenix.Socket.Socket Msg
        phxSocketWithListener =
            phxSocket
                |> Phoenix.Socket.on "follower_joined" channelName FollowerJoined

        initModel : Model
        initModel =
            { game = Game.init
            , phxSocket = phxSocketWithListener
            }
    in
        ( initModel
        , Cmd.map PhoenixMsg phxCmd
        )


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
    case JD.decodeValue Leader.Init.State.decoder raw of
        Ok state ->
            Init state

        Err error ->
            defaultModel
