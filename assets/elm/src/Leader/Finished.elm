module Leader.Finished exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (src, style, class)
import Json.Decode as JD exposing (field)
import Leader.Finished.Model exposing (..)
import Socket exposing (socketServer)
import Phoenix.Channel
import Phoenix.Socket
import Views.Logo exposing (logo, animatedLogo)


init : String -> ( Model, Cmd Msg )
init gameId =
    let
        channelName =
            ("leader:finished:" ++ gameId)

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
                    { model | state = Finishing state } ! []

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
            animatedLogo

        Finishing { state } ->
            case state of
                "innocents" ->
                    div [] [ logo, text "Innocents win" ]

                "mafia" ->
                    div [ class "margin-top" ]
                        [ img [ src "/images/mafia-wins.gif", style [ ( "width", "70%" ) ] ] []
                        ]

                _ ->
                    div [] [ logo, text "Somebody else wins" ]
