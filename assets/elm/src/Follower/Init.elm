module Follower.Init exposing (..)

import Player
import Html exposing (Html, div, text, button)
import Json.Encode as JE
import Phoenix.Channel
import Phoenix.Socket
import Follower.Init.State as InitState exposing (State)
import Follower.Model exposing (..)
import Array exposing (Array)
import Follower.Init.Msg exposing (..)


-- CONSTANTS


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


type alias Msg =
    Follower.Init.Msg.Msg


init : String -> String -> ( Model, Cmd Msg )
init gameId playerId =
    let
        channelName =
            ("rooms:followers:init:" ++ gameId)

        channel =
            Phoenix.Channel.init channelName
                |> Phoenix.Channel.withPayload (JE.object [ ( "player_id", JE.string playerId ) ])
                |> Phoenix.Channel.onJoin LoadGame

        initPhxSocket =
            Phoenix.Socket.init socketServer
                |> Phoenix.Socket.withDebug

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel initPhxSocket

        phxSocketWithListener : Phoenix.Socket.Socket Msg
        phxSocketWithListener =
            phxSocket
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


subscriptions : State -> Sub Msg
subscriptions state =
    Phoenix.Socket.listen state.phxSocket PhoenixMsg


view : State -> Html Msg
view { players, total } =
    div []
        [ div [] [ text "Waiting other users to connect..." ]
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