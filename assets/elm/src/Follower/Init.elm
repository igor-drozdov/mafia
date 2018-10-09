module Follower.Init exposing (..)

import Html exposing (Html, div, text, button, img)
import Html.Attributes exposing (src)
import Json.Decode as JD exposing (field)
import Phoenix.Channel
import Phoenix.Socket
import Follower.Init.Model exposing (..)
import Socket exposing (socketServer)
import Player


init : String -> String -> ( Model, Cmd Msg )
init gameId playerId =
    let
        channelName =
            ("followers:init:" ++ gameId ++ ":" ++ playerId)

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
                |> Phoenix.Socket.on "role_received" channelName RoleReceived
                |> Phoenix.Socket.on "start_game" channelName Transition
    in
        ( { phxSocket = phxSocketWithListener, role = Nothing, players = [] }
        , Cmd.map PhoenixMsg phxCmd
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        RoleReceived raw ->
            case JD.decodeValue decoder raw of
                Ok { role, players } ->
                    { model | role = role, players = players } ! []

                Err error ->
                    model ! []

        LoadGame _ ->
            model ! []

        _ ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg


view : Model -> Html Msg
view { role, players } =
    case role of
        Nothing ->
            div []
                [ div [] [ text "Waiting other players to connect..." ]
                ]

        Just role ->
            div []
                [ div [] [ text ("You are " ++ role) ]
                , img [ src ("/images/" ++ role ++ ".jpg") ] []
                , displayOthers players
                ]


displayOthers : List Player.Model -> Html Msg
displayOthers players =
    case players of
        [] ->
            div [] []

        mafias ->
            div []
                [ div []
                    [ text ("Other players, who are also mafia: " ++ (String.join ", " <| List.map .name mafias))
                    ]
                ]
