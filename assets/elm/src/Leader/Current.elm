module Leader.Current exposing (init, socketMessages, subscriptions, update, view)

import Html exposing (Html, div, text, span)
import Html.Attributes exposing (class, id)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Leader.Current.Model exposing (..)
import Ports.Audio as Audio
import Time
import Views.Logo exposing (animatedCircuit, animatedLogo, logo)


socketMessages : List ( String, JE.Value -> Msg )
socketMessages =
    [ ( "play_audio", AudioReceived )
    , ( "city_wakes", CityWakes )
    , ( "player_can_speak", PlayerCanSpeak )
    , ( "player_speaks", PlayerSpeaks )
    , ( "player_chooses", PlayerChooses )
    , ( "selection_begins", SelectionBegins )
    , ( "finish_game", Transition )
    ]


init : JD.Value -> Result JD.Error Model
init raw =
    Result.map Playing (JD.decodeValue decoder raw)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( AudioReceived raw, _ ) ->
            ( model
            , Audio.playAudio raw
            )

        ( CityWakes raw, _ ) ->
            case JD.decodeValue decoder raw of
                Ok state ->
                    ( CityAwaken state, Cmd.none )

                Err error ->
                    ( model
                    , Cmd.none
                    )

        ( PlayerCanSpeak raw, _ ) ->
            case JD.decodeValue playerDecoder raw of
                Ok state ->
                    ( PlayerAbleToSpeak state, Cmd.none )

                Err error ->
                    ( model
                    , Cmd.none
                    )

        ( PlayerSpeaks raw, _ ) ->
            case JD.decodeValue playerSpeakingDecoder raw of
                Ok state ->
                    ( PlayerSpeaking state, Cmd.none )

                Err error ->
                    ( model
                    , Cmd.none
                    )

        ( Tick _, PlayerSpeaking { player, elapsed } ) ->
            ( PlayerSpeaking (PlayerSpeakingState player (elapsed - 1000)), Cmd.none )

        ( PlayerChooses raw, _ ) ->
            case JD.decodeValue playerDecoder raw of
                Ok state ->
                    ( PlayerChoosing state, Cmd.none )

                Err error ->
                    ( model
                    , Cmd.none
                    )

        ( SelectionBegins _, _ ) ->
            ( Playing (PlayingState []), Cmd.none )

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick


view : Model -> Html Msg
view model =
    case model of
        Playing state ->
            div []
                [ logo
                , text (String.fromInt (List.length state.players) ++ " players")
                ]

        CityAwaken state ->
            div [ class "ostrisized-player" ]
                [ logo
                , div [] [ text "The following players is ostracized from city:" ]
                , div []
                    [ text (String.join ", " (List.map .name state.players))
                    ]
                ]

        PlayerAbleToSpeak player ->
            div [ id "player-can-speak" ]
                [ logo
                , div []
                    [ span [ class "colored" ] [ text player.name ]
                    , span [] [ text ", speak!" ]
                    ]
                ]

        PlayerSpeaking { player, elapsed } ->
            div [ id "player-speaks" ]
                [ animatedCircuit (div [ class "elapsed" ] [ text (String.fromInt (elapsed // 1000)) ])
                , div []
                    [ span [ class "colored" ] [ text player.name ]
                    , span [] [ text " speaks!" ]
                    ]
                ]

        PlayerChoosing player ->
            div []
                [ animatedLogo
                , div [] [ text "The following player chooses:" ]
                , div []
                    [ text player.name
                    ]
                ]
