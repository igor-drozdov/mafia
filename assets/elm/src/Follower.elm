module Follower exposing (..)

--where

import Html exposing (Html, div, text)
import Platform.Cmd
import Follower.Init as Init
import Follower.Current as Current
import Follower.Finished as Finished
import Follower.Model exposing (..)


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



-- CONSTANTS


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"



-- MODEL


type Msg
    = InitMsg Init.Msg
    | CurrentMsg Current.Msg
    | FinishedMsg Finished.Msg


init : Flags -> ( Model, Cmd Msg )
init { gameId, playerId, state } =
    case state of
        "current" ->
            let
                ( model, subMsg ) =
                    Current.init gameId
            in
                ( model, Cmd.map CurrentMsg subMsg )

        "finished" ->
            let
                ( model, subMsg ) =
                    Finished.init gameId
            in
                ( model, Cmd.map FinishedMsg subMsg )

        _ ->
            let
                ( model, subMsg ) =
                    Init.init gameId playerId
            in
                ( model, Cmd.map InitMsg subMsg )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Init state ->
            Sub.map InitMsg <| Init.subscriptions state

        _ ->
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
