module Follower.Current exposing (..)

import Html exposing (Html, div, text)
import Array exposing (fromList)
import Phoenix.Channel
import Phoenix.Socket
import Follower.Current.Model exposing (..)


init : String -> ( Model, Cmd Msg )
init gameId =
    let
        channelName =
            ("followers:current:" ++ gameId)

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
                |> Phoenix.Socket.on "play_audio" channelName AudioReceived
    in
        ( { phxSocket = phxSocketWithListener, state = Loading }
        , Cmd.map PhoenixMsg phxCmd
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Agree raw ->
            model ! []

        NoOp ->
            model ! []


view : Model -> Html Msg
view model =
    div [] []
