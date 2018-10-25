module Follower.Current exposing (init, socketMessages, subscriptions, update, view, viewCandidate)

import Follower.Current.Model exposing (..)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as JD
import Json.Encode as JE
import Player
import Ports.DeviceOrientation as DeviceOrientation
import Task
import Views.Logo exposing (logo)


socketMessages : List ( String, JE.Value -> Msg )
socketMessages =
    [ ( "player_can_speak", PlayerCanSpeak )
    , ( "candidates_received", CandidatesReceived )
    , ( "player_chosen", PlayerChosen )
    ]


init : JE.Value -> Result JD.Error Model
init raw =
    Result.map Playing (JD.decodeValue decoder raw)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( PlayerCanSpeak raw, Playing state ) ->
            ( PlayerAbleToSpeak state, Cmd.none )

        ( PlayerReadyToSpeak, PlayerAbleToSpeak state ) ->
            let
                command =
                    Task.succeed (PushSocket "speak" (JE.object []))
                        |> Task.perform identity
            in
            ( Playing state, command )

        ( DeviceOrientationChanged orientation, PlayerAbleToSpeak state ) ->
            case orientation of
                Ok { beta, gamma } ->
                    if abs (90 - beta) < 5 && abs gamma < 5 then
                        let
                            command =
                                Task.succeed (PushSocket "speak" (JE.object []))
                                    |> Task.perform identity
                        in
                        ( Playing state, command )

                    else
                        ( model, Cmd.none )

                Err error ->
                    ( model, Cmd.none )

        ( CandidatesReceived raw, _ ) ->
            case JD.decodeValue decoder raw of
                Ok state ->
                    ( PlayerChoosing state, Cmd.none )

                Err error ->
                    ( model, Cmd.none )

        ( ChooseCandidate playerId, PlayerChoosing state ) ->
            let
                payload =
                    JE.object [ ( "player_id", JE.string playerId ) ]

                command =
                    Task.succeed (PushSocket "choose_candidate" payload)
                        |> Task.perform identity
            in
            ( model, command )

        ( PlayerChosen _, PlayerChoosing state ) ->
            ( Playing state, Cmd.none )

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    DeviceOrientation.listen DeviceOrientationChanged


view : Model -> Html Msg
view model =
    case model of
        Playing state ->
            logo

        PlayerAbleToSpeak _ ->
            div [ class "pure-form" ]
                [ logo
                , button [ class "btn btn-danger pure-input-1-2", onClick PlayerReadyToSpeak ] [ text "Speak" ]
                ]

        PlayerChoosing state ->
            div [ class "pure-form" ] <| logo :: List.map viewCandidate state.players


viewCandidate : Player.Model -> Html Msg
viewCandidate player =
    div []
        [ button [ class "btn btn-danger pure-input-1-2", onClick (ChooseCandidate player.id) ]
            [ text player.name
            ]
        ]
