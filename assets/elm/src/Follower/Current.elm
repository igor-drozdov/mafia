module Follower.Current exposing (..)

import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Phoenix.Channel
import Json.Decode as JD
import Json.Encode as JE
import Phoenix.Socket
import Phoenix.Push
import Follower.Current.Model exposing (..)
import Player
import Views.Logo exposing (logo, animatedLogo)
import Ports.DeviceOrientation as DeviceOrientation


init : String -> String -> String -> ( Model, Cmd Msg )
init gameId playerId socketServer =
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
                |> Phoenix.Socket.on "player_can_speak" channelName PlayerCanSpeak
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
            case JD.decodeValue decoder raw of
                Ok state ->
                    { model | state = Playing state } ! []

                Err error ->
                    model ! []

        ( PlayerCanSpeak raw, Playing state ) ->
            { model | state = PlayerAbleToSpeak } ! []

        ( PlayerReadyToSpeak, PlayerAbleToSpeak ) ->
            let
                push_ =
                    Phoenix.Push.init "speak" model.channelName

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push push_ model.phxSocket
            in
                { model | phxSocket = phxSocket, state = Loading }
                    ! [ Cmd.map PhoenixMsg phxCmd ]

        ( DeviceOrientationChanged orientation, PlayerAbleToSpeak ) ->
            case orientation of
                Ok { beta, gamma } ->
                    if (abs (90 - beta) < 5 && abs gamma < 5) then
                        let
                            push_ =
                                Phoenix.Push.init "speak" model.channelName

                            ( phxSocket, phxCmd ) =
                                Phoenix.Socket.push push_ model.phxSocket
                        in
                            { model | phxSocket = phxSocket, state = Loading }
                                ! [ Cmd.map PhoenixMsg phxCmd ]
                    else
                        model ! []

                Err error ->
                    model ! []

        ( CandidatesReceived raw, _ ) ->
            case JD.decodeValue decoder raw of
                Ok state ->
                    { model | state = PlayerChoosing state } ! []

                Err error ->
                    model ! []

        ( ChooseCandidate playerId, PlayerChoosing state ) ->
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

        ( PlayerChosen _, PlayerChoosing state ) ->
            { model | state = Playing state } ! []

        _ ->
            model ! []


decoder1 : JD.Decoder Orientation
decoder1 =
    JD.map3 Orientation
        (JD.map floor (JD.field "alpha" JD.float))
        (JD.map floor (JD.field "beta" JD.float))
        (JD.map floor (JD.field "gamma" JD.float))


decode : JE.Value -> Result String Orientation
decode =
    JD.decodeValue decoder1


listen : (Result String Orientation -> msg) -> Sub msg
listen msg =
    DeviceOrientation.listener (decode >> msg)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Phoenix.Socket.listen model.phxSocket PhoenixMsg, listen DeviceOrientationChanged ]



--, DeviceOrientation.listen DeviceOrientationChanged ]


view : Model -> Html Msg
view model =
    case model.state of
        Loading ->
            animatedLogo

        Playing state ->
            logo

        PlayerAbleToSpeak ->
            div [ class "pure-form" ]
                [ logo
                , button [ class "btn btn-danger pure-input-1-2", onClick PlayerReadyToSpeak ] [ text "Speak" ]
                ]

        PlayerChoosing state ->
            div [ class "pure-form" ] <| logo :: (List.map viewCandidate state.players)


viewCandidate : Player.Model -> Html Msg
viewCandidate player =
    div []
        [ button [ class "btn btn-danger pure-input-1-2", onClick (ChooseCandidate player.id) ]
            [ text player.name
            ]
        ]
