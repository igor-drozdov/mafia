module Follower.Current exposing (..)

import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)
import Phoenix.Channel
import Json.Decode as JD
import Json.Encode as JE
import Phoenix.Socket
import Phoenix.Push
import Follower.Current.Model exposing (..)
import Socket exposing (socketServer)
import Player
import Debug


init : String -> String -> ( Model, Cmd Msg )
init gameId playerId =
    let
        channelName =
            ("followers:current:" ++ gameId ++ ":" ++ playerId)

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
                |> Phoenix.Socket.on "candidates_received" channelName CandidatesReceived
                |> Phoenix.Socket.on "player_chosen" channelName PlayerChosen
    in
        ( { phxSocket = phxSocketWithListener, channelName = channelName, state = Loading }
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
            case (Debug.log "value: " (JD.decodeValue decoder (Debug.log "raw: " raw))) of
                Ok state ->
                    { model | state = Playing state } ! []

                Err error ->
                    model ! []

        ( CandidatesReceived raw, Playing state ) ->
            case Debug.log "value : " (JD.decodeValue decoder (Debug.log "raw" raw)) of
                Ok state ->
                    { model | state = MafiaAwaken state } ! []

                Err error ->
                    model ! []

        ( ChooseCandidate playerId, MafiaAwaken state ) ->
            let
                payload =
                    JE.object [ ( "player_id", JE.string playerId ) ]

                push_ =
                    Phoenix.Push.init "choose_candidate" model.channelName
                        |> Phoenix.Push.withPayload payload

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push push_ model.phxSocket
            in
                { model | phxSocket = phxSocket }
                    ! [ Cmd.map PhoenixMsg phxCmd ]

        ( PlayerChosen _, MafiaAwaken state ) ->
            { model | state = Playing state } ! []

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
            div [] [ text (toString (List.length state.players)) ]

        MafiaAwaken state ->
            div [] (List.map viewCandidate state.players)


viewCandidate : Player.Model -> Html Msg
viewCandidate player =
    div []
        [ button [ onClick (ChooseCandidate player.id) ]
            [ text player.name
            ]
        ]
