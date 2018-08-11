module Leader.Init exposing (..)

import Player
import Html exposing (Html, div, text, button)
import Json.Decode as JD exposing (field)
import Phoenix.Channel
import Phoenix.Socket
import Leader.Init.State as InitState exposing (State)
import Leader.Model exposing (..)
import Array exposing (Array)
import List.Extra exposing (find)
import Leader.Init.Msg exposing (..)


-- CONSTANTS


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


type alias Msg =
    Leader.Init.Msg.Msg


init : String -> ( Model, Cmd Msg )
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
    in
        ( Init (InitState.init phxSocketWithListener)
        , Cmd.map PhoenixMsg phxCmd
        )


update : Msg -> State -> ( Model, Cmd Msg )
update msg state =
    case msg of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg state.phxSocket
            in
                ( Init { state | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        LoadGame _ ->
            Init state ! []

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
                                Init { state | players = Array.push player state.players } ! []

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
