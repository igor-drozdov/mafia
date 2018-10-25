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
import Ports.Socket as Socket
import Views.Logo exposing (animatedLogo)


-- MAIN


type alias Flags =
    { gameId : String
    , playerId : String
    , state : String
    }


main : Program Flags Model Msg
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
    | UnknownSocketEvent String JE.Value


type alias Model =
    { channel : Socket.Channel Msg
    , state : State
    }


type State
    = InitModel Init.Model
    | CurrentModel Current.Model
    | FinishedModel Finished.Model
    | Loading


init : Flags -> ( Model, Cmd Msg )
init { gameId, playerId, state } =
    let
        initChannel =
            Socket.init (LoadGame state) UnknownSocketEvent

        assignListener wrapper ( eventName, cmd ) channel =
            channel
                |> Socket.on eventName (wrapper << cmd)

        assignListeners wrapper messages channel =
            List.foldl (assignListener wrapper) channel messages

        channelWithListeners =
            initChannel
                |> assignListeners CurrentMsg CurrentWidget.socketMessages
                |> assignListeners InitMsg InitWidget.socketMessages

        joinCommand =
            Socket.join channelWithListeners
    in
        ( Model channelWithListeners Loading, joinCommand )



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
            [ Socket.listen model.channel ]
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

        ( CurrentMsg (Current.PushSocket event payload), CurrentModel state ) ->
            ( model, Socket.push event payload )

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
