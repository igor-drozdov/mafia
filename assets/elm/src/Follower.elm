module Follower exposing (..)

--where

import Html exposing (Html, div, text)
import Platform.Cmd
import Follower.Init as InitWidget
import Follower.Current as CurrentWidget
import Follower.Finished as FinishedWidget
import Follower.Init.Model as Init
import Follower.Current.Model as Current
import Follower.Finished.Model as Finished
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Socket exposing (WithSocket)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Views.Logo exposing (animatedLogo)


-- MAIN


type alias Flags =
    { gameId : String
    , playerId : String
    , state : String
    }


main : Program (WithSocket Flags) Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type Msg
    = InitMsg Init.Msg
    | CurrentMsg Current.Msg
    | FinishedMsg Finished.Msg
    | LoadGame String JE.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , channel : String
    , state : State
    }


type State
    = InitModel Init.Model
    | CurrentModel Current.Model
    | FinishedModel Finished.Model
    | Loading


init : WithSocket Flags -> ( Model, Cmd Msg )
init { gameId, playerId, state, socketServer } =
    let
        channelName =
            ("followers:" ++ gameId ++ ":" ++ playerId)

        channel =
            Phoenix.Channel.init channelName
                |> Phoenix.Channel.onJoin (LoadGame state)

        initPhxSocket =
            Phoenix.Socket.init socketServer
                |> Phoenix.Socket.withDebug

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel initPhxSocket

        assignListener wrapper ( msg, cmd ) socket =
            socket
                |> Phoenix.Socket.on msg channelName (wrapper << cmd)

        assignListeners wrapper messages phxSocket =
            List.foldl (assignListener wrapper) phxSocket messages

        phxSocketWithListeners =
            phxSocket
                |> assignListeners CurrentMsg CurrentWidget.socketMessages
                |> assignListeners InitMsg InitWidget.socketMessages
    in
        ( Model phxSocketWithListeners channelName Loading, Cmd.map PhoenixMsg phxCmd )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        childSubscriptions =
            case model.state of
                InitModel state ->
                    Sub.map InitMsg <| InitWidget.subscriptions state

                CurrentModel state ->
                    Sub.map CurrentMsg <| CurrentWidget.subscriptions state

                _ ->
                    Sub.none

        mainSubscriptions =
            [ Phoenix.Socket.listen model.phxSocket PhoenixMsg ]
    in
        Sub.batch (childSubscriptions :: mainSubscriptions)



-- UPDATE


decoder : JD.Decoder Flags
decoder =
    JD.map3 Flags
        (field "game_id" JD.string)
        (field "player_id" JD.string)
        (field "state" JD.string)


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

        ( LoadGame state raw, Loading ) ->
            let
                initStateResult =
                    case state of
                        "current" ->
                            Result.map CurrentModel <| CurrentWidget.init raw

                        "finished" ->
                            Result.map FinishedModel <| FinishedWidget.init raw

                        _ ->
                            Result.map InitModel <| InitWidget.init raw
            in
                case initStateResult of
                    Ok initState ->
                        ( { model | state = initState }, Cmd.none )

                    Err err ->
                        ( model, Cmd.none )

        ( InitMsg (Init.Transition raw), InitModel modelState ) ->
            case CurrentWidget.init raw of
                Ok state ->
                    ( { model | state = CurrentModel state }, Cmd.none )

                Err err ->
                    ( model, Cmd.none )

        ( InitMsg m, InitModel state ) ->
            let
                ( newModel, subCmd ) =
                    InitWidget.update m state
            in
                { model | state = InitModel newModel }
                    ! [ Cmd.map InitMsg subCmd ]

        ( CurrentMsg (Current.PushSocket msg payload), CurrentModel state ) ->
            let
                push_ =
                    Phoenix.Push.init msg model.channel
                        |> Phoenix.Push.withPayload payload

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push push_ model.phxSocket
            in
                { model | phxSocket = phxSocket }
                    ! [ Cmd.map PhoenixMsg phxCmd ]

        ( CurrentMsg m, CurrentModel state ) ->
            let
                ( newModel, subCmd ) =
                    CurrentWidget.update m state
            in
                { model | state = CurrentModel newModel }
                    ! [ Cmd.map CurrentMsg subCmd ]

        ( FinishedMsg m, FinishedModel state ) ->
            let
                ( newModel, subCmd ) =
                    FinishedWidget.update m state
            in
                { model | state = FinishedModel newModel }
                    ! [ Cmd.map FinishedMsg subCmd ]

        _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.state of
        Loading ->
            animatedLogo

        InitModel state ->
            Html.map InitMsg <| InitWidget.view state

        CurrentModel state ->
            Html.map CurrentMsg <| CurrentWidget.view state

        FinishedModel state ->
            Html.map FinishedMsg <| FinishedWidget.view state
