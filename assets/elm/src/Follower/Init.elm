module Follower.Init exposing (..)

import Html exposing (Html, div, text, button, img)
import Html.Attributes exposing (src)
import Json.Encode as JE
import Json.Decode as JD
import Json.Decode as JD exposing (field)
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
    in
        ( { phxSocket = phxSocketWithListener, role = Nothing }
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
            case JD.decodeValue (field "role" JD.string) raw of
                Ok role ->
                    { model | role = Just role } ! []

                Err error ->
                    model ! []

        LoadGame _ ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg


view : Model -> Html Msg
view { role } =
    case role of
        Nothing ->
            div []
                [ div [] [ text "Waiting other users to connect..." ]
                ]

        Just role ->
            div []
                [ div [] [ text ("You are " ++ role) ]
                , img [ src ("/images/" ++ role ++ ".jpg") ] []
                ]
