module Leader.Current exposing (..)

import Html exposing (Html, div, text)
import Phoenix.Channel
import Phoenix.Socket
import Leader.Current.Model exposing (..)
import Ports.Audio as Audio
import Socket exposing (socketServer)


init : String -> ( Model, Cmd Msg )
init gameId =
    let
        channelName =
            ("leader:current:" ++ gameId)

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
    case ( msg, model.state ) of
        ( PhoenixMsg msg, _ ) ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        ( LoadGame raw, Loading ) ->
            decode raw model ! []

        ( AudioReceived raw, _ ) ->
            model ! [ Audio.playAudio raw ]

        _ ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg


view : Model -> Html Msg
view model =
    case model.state of
        Loading ->
            div [] [ text "Loading..." ]

        Playing state ->
            div [] [ text ((toString (List.length state.players)) ++ " players") ]
