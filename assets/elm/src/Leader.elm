module Leader exposing (..)

--where

import Html exposing (Html)
import Platform.Cmd
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Leader.Init as InitWidget
import Leader.Current as CurrentWidget
import Leader.Finished as FinishedWidget
import Leader.Init.Model as Init
import Leader.Current.Model as Current
import Leader.Finished.Model as Finished
import Socket exposing (WithSocket)
import Phoenix.Socket
import Phoenix.Channel
import Views.Logo exposing (animatedLogo)


-- MAIN


main : Program (WithSocket Flags) Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Flags =
    { gameId : String
    , state : String
    }


init : WithSocket Flags -> ( Model, Cmd Msg )
init { gameId, socketServer, state } =
    let
        channelName =
            ("leader:" ++ gameId)

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
        ( { phxSocket = phxSocketWithListeners, state = Loading }, Cmd.map PhoenixMsg phxCmd )



-- MODEL


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , state : State
    }


type State
    = InitModel Init.Model
    | CurrentModel Current.Model
    | FinishedModel Finished.Model
    | Loading


type Msg
    = InitMsg Init.Msg
    | CurrentMsg Current.Msg
    | FinishedMsg Finished.Msg
    | LoadGame String JE.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)



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

                FinishedModel state ->
                    Sub.map FinishedMsg <| FinishedWidget.subscriptions state

                _ ->
                    Sub.none

        mainSubscriptions =
            [ Phoenix.Socket.listen model.phxSocket PhoenixMsg ]
    in
        Sub.batch (childSubscriptions :: mainSubscriptions)



-- UPDATE


decoder : JD.Decoder Flags
decoder =
    JD.map2 Flags
        (field "game_id" JD.string)
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

        ( LoadGame state raw, _ ) ->
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

        ( InitMsg (Init.Transition raw), _ ) ->
            case CurrentWidget.init raw of
                Ok state ->
                    ( { model | state = CurrentModel state }, Cmd.none )

                Err err ->
                    ( model, Cmd.none )

        ( CurrentMsg (Current.Transition raw), _ ) ->
            case FinishedWidget.init raw of
                Ok state ->
                    ( { model | state = FinishedModel state }, Cmd.none )

                Err err ->
                    ( model, Cmd.none )

        ( InitMsg m, InitModel state ) ->
            let
                ( newModel, subCmd ) =
                    InitWidget.update m state
            in
                { model | state = InitModel newModel }
                    ! [ Cmd.map InitMsg subCmd ]

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
            model ! []



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
