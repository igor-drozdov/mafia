module Leader exposing (..)

--where

import Html exposing (Html)
import Platform.Cmd
import Json.Decode as JD exposing (field)
import Leader.Init as InitWidget
import Leader.Current as CurrentWidget
import Leader.Finished as FinishedWidget
import Leader.Init.Model as Init
import Leader.Current.Model as Current
import Leader.Finished.Model as Finished
import Socket exposing (WithSocket)


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
    case state of
        "current" ->
            let
                ( model, subMsg ) =
                    CurrentWidget.init gameId socketServer
            in
                ( CurrentModel model, Cmd.map CurrentMsg subMsg )

        "finished" ->
            let
                ( model, subMsg ) =
                    FinishedWidget.init gameId socketServer
            in
                ( FinishedModel model, Cmd.map FinishedMsg subMsg )

        _ ->
            let
                ( model, subMsg ) =
                    InitWidget.init gameId socketServer
            in
                ( InitModel model, Cmd.map InitMsg subMsg )



-- MODEL


type Model
    = InitModel Init.Model
    | CurrentModel Current.Model
    | FinishedModel Finished.Model


type Msg
    = InitMsg Init.Msg
    | CurrentMsg Current.Msg
    | FinishedMsg Finished.Msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        InitModel state ->
            Sub.map InitMsg <| InitWidget.subscriptions state

        CurrentModel state ->
            Sub.map CurrentMsg <| CurrentWidget.subscriptions state

        FinishedModel state ->
            Sub.map FinishedMsg <| FinishedWidget.subscriptions state



-- UPDATE


decoder : JD.Decoder Flags
decoder =
    JD.map2 Flags
        (field "game_id" JD.string)
        (field "state" JD.string)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( InitMsg (Init.Transition raw), InitModel modelState ) ->
            case JD.decodeValue decoder raw of
                Ok { gameId, state } ->
                    init { gameId = gameId, state = state, socketServer = modelState.phxSocket.path }

                Err _ ->
                    model ! []

        ( InitMsg m, InitModel state ) ->
            let
                ( newModel, subCmd ) =
                    InitWidget.update m state
            in
                InitModel newModel
                    ! [ Cmd.map InitMsg subCmd ]

        ( CurrentMsg (Current.Transition raw), CurrentModel modelState ) ->
            case JD.decodeValue decoder raw of
                Ok { gameId, state } ->
                    init { gameId = gameId, state = state, socketServer = modelState.phxSocket.path }

                Err _ ->
                    model ! []

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
