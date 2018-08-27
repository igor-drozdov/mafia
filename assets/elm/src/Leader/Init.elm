module Leader.Init exposing (..)

import Player
import Html exposing (Html, div, text, button)
import Json.Decode as JD exposing (field)
import Phoenix.Channel
import Phoenix.Socket
import Leader.Init.Model exposing (..)
import Array exposing (Array, fromList)
import List.Extra exposing (find)
import Ports.Audio exposing (playAudio)


-- CONSTANTS


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


init : String -> ( Model, Cmd Msg )
init gameId =
    let
        channelName =
            ("leader:init:" ++ gameId)

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
                |> Phoenix.Socket.on "roles_assigned" channelName RolesAssigned
                |> Phoenix.Socket.on "round_begins" channelName Transition
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

        ( RolesAssigned raw, _ ) ->
            model ! [ playAudio raw ]

        ( FollowerJoined raw, Wait state ) ->
            case JD.decodeValue Player.decoder raw of
                Ok player ->
                    let
                        foundModel =
                            find (\p -> p.id == player.id) (Array.toList state.players)

                        newState =
                            Wait { state | players = Array.push player state.players }
                    in
                        case foundModel of
                            Just _ ->
                                model ! []

                            Nothing ->
                                { model | state = newState } ! []

                Err error ->
                    model ! []

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

        Wait { total, players } ->
            if (Array.length players) == total then
                div [] [ text "All the players joined!" ]
            else
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
