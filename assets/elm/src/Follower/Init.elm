module Follower.Init exposing (..)

import Html exposing (Html, div, text, button)
import Json.Encode as JE
import Phoenix.Channel
import Phoenix.Socket
import Follower.Init.Model exposing (..)


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


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
        ( { phxSocket = phxSocketWithListener }
        , Cmd.map PhoenixMsg phxCmd
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg state =
    case msg of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg state.phxSocket
            in
                ( { state | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        LoadGame _ ->
            state ! []


subscriptions : Model -> Sub Msg
subscriptions state =
    Phoenix.Socket.listen state.phxSocket PhoenixMsg


view : Model -> Html Msg
view model =
    div []
        [ div [] [ text "Waiting other users to connect..." ]
        ]
