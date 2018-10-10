module Leader.Current exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Phoenix.Channel
import Phoenix.Socket
import Json.Decode as JD exposing (field)
import Leader.Current.Model exposing (..)
import Ports.Audio as Audio
import Socket exposing (socketServer)
import Player


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
                |> Phoenix.Socket.on "city_wakes" channelName CityWakes
                |> Phoenix.Socket.on "player_speaks" channelName PlayerSpeaks
                |> Phoenix.Socket.on "player_chooses" channelName PlayerChooses
                |> Phoenix.Socket.on "selection_begins" channelName SelectionBegins
                |> Phoenix.Socket.on "finish_game" channelName Transition
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
            case JD.decodeValue decoder raw of
                Ok state ->
                    { model | state = Playing state } ! []

                Err error ->
                    model ! []

        ( AudioReceived raw, _ ) ->
            model ! [ Audio.playAudio raw ]

        ( CityWakes raw, _ ) ->
            case JD.decodeValue decoder raw of
                Ok state ->
                    { model | state = CityAwaken state } ! []

                Err error ->
                    model ! []

        ( PlayerSpeaks raw, _ ) ->
            case JD.decodeValue (field "player" Player.decoder) raw of
                Ok state ->
                    { model | state = PlayerSpeaking state } ! []

                Err error ->
                    model ! []

        ( PlayerChooses raw, _ ) ->
            case JD.decodeValue (field "player" Player.decoder) raw of
                Ok state ->
                    { model | state = PlayerChoosing state } ! []

                Err error ->
                    model ! []

        ( SelectionBegins _, _ ) ->
            { model | state = Loading } ! []

        _ ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg


view : Model -> Html Msg
view { state } =
    case state of
        Loading ->
            animatedLogo

        Playing state ->
            div []
                [ logo
                , text ((toString (List.length state.players)) ++ " players")
                ]

        CityAwaken state ->
            div []
                [ logo
                , div [] [ text "The following players is ostracized from city:" ]
                , div []
                    [ text (String.join ", " (List.map .name state.players))
                    ]
                ]

        PlayerSpeaking { player, elapsed } ->
            div []
                [ div [] [ text "The following player speaks:" ]
                , div []
                    [ text player.name
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
