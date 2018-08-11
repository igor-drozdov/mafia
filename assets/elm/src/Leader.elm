module Leader exposing (..)

--where

import Html exposing (Html)
import Platform.Cmd
import Leader.Init as Init
import Leader.Current as Current
import Leader.Finished as Finished


-- MAIN


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- CONSTANTS


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"



-- INIT


type alias Flags =
    { gameId : String
    , state : String
    }


init : Flags -> Model
init { gameId, state } =
    case state of
        "current" ->
            Current.init gameId

        "finished" ->
            Finished.init gameId

        _ ->
            Init.init gameId



-- MODEL


type Msg
    = InitMsg Init.Msg
    | CurrentMsg Current.Msg
    | FinishedMsg Finished.Msg


type Model
    = Init InitState.State
    | Current CurrentState.State
    | Finished FinishedState.State



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( InitMsg m, Init state ) ->
            let
                ( newModel, subCmd ) =
                    Init.update m state
            in
                newModel
                    ! [ Cmd.map InitMsg subCmd ]

        ( CurrentMsg m, Current state ) ->
            let
                ( newModel, subCmd ) =
                    Current.update m state
            in
                newModel
                    ! [ Cmd.map CurrentMsg subCmd ]

        ( FinishedMsg m, Finished state ) ->
            let
                ( newModel, subCmd ) =
                    Finished.update m state
            in
                newModel
                    ! [ Cmd.map FinishedMsg subCmd ]

        _ ->
            model ! []



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Init state ->
            Html.map InitMsg <| Init.view state

        Current state ->
            Html.map CurrentMsg <| Current.view state

        Finished state ->
            Html.map FinishedMsg <| Finished.view state
