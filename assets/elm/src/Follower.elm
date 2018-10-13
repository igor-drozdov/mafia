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
import Socket exposing (WithSocket)


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


type Model
    = InitModel Init.Model
    | CurrentModel Current.Model
    | FinishedModel Finished.Model


init : WithSocket Flags -> ( Model, Cmd Msg )
init { gameId, playerId, state, socketServer } =
    case state of
        "current" ->
            let
                ( model, subMsg ) =
                    CurrentWidget.init gameId playerId socketServer
            in
                ( CurrentModel model, Cmd.map CurrentMsg subMsg )

        "finished" ->
            let
                ( model, subMsg ) =
                    FinishedWidget.init gameId
            in
                ( FinishedModel model, Cmd.map FinishedMsg subMsg )

        _ ->
            let
                ( model, subMsg ) =
                    InitWidget.init gameId playerId socketServer
            in
                ( InitModel model, Cmd.map InitMsg subMsg )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        InitModel state ->
            Sub.map InitMsg <| InitWidget.subscriptions state

        CurrentModel state ->
            Sub.map CurrentMsg <| CurrentWidget.subscriptions state

        _ ->
            Sub.none



-- UPDATE


decoder : JD.Decoder Flags
decoder =
    JD.map3 Flags
        (field "game_id" JD.string)
        (field "player_id" JD.string)
        (field "state" JD.string)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( InitMsg (Init.Transition raw), InitModel modelState ) ->
            case JD.decodeValue decoder raw of
                Ok { gameId, playerId, state } ->
                    init { gameId = gameId, playerId = playerId, state = state, socketServer = modelState.phxSocket.path }

                Err _ ->
                    model ! []

        ( InitMsg m, InitModel state ) ->
            let
                ( newModel, subCmd ) =
                    InitWidget.update m state
            in
                InitModel newModel
                    ! [ Cmd.map InitMsg subCmd ]

        ( CurrentMsg m, CurrentModel state ) ->
            let
                ( newModel, subCmd ) =
                    CurrentWidget.update m state
            in
                CurrentModel newModel
                    ! [ Cmd.map CurrentMsg subCmd ]

        ( FinishedMsg m, FinishedModel state ) ->
            let
                ( newModel, subCmd ) =
                    FinishedWidget.update m state
            in
                FinishedModel newModel
                    ! [ Cmd.map FinishedMsg subCmd ]

        _ ->
            model ! []



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        InitModel state ->
            Html.map InitMsg <| InitWidget.view state

        CurrentModel state ->
            Html.map CurrentMsg <| CurrentWidget.view state

        FinishedModel state ->
            Html.map FinishedMsg <| FinishedWidget.view state
