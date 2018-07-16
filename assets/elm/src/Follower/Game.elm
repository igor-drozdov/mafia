module Follower.Game exposing (..)

import Html exposing (Html, div, text)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Player
import Follower.Game.Init as Init
import Follower.Game.Current as Current
import Follower.Game.Finished as Finished
import Follower.Game.Model exposing (..)


type alias Model =
    Follower.Game.Model.Model


type Msg
    = LoadGame JE.Value
    | InitMsg Init.Msg
    | CurrentMsg Current.Msg
    | FinishedMsg Finished.Msg


init : Model
init =
    Loading


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( LoadGame raw, Loading ) ->
            case JD.decodeValue decoder raw of
                Ok { state, players } ->
                    case state of
                        "init" ->
                            Init.init players ! []

                        "current" ->
                            Current.init players ! []

                        "finished" ->
                            Finished.init players ! []

                        _ ->
                            model ! []

                Err error ->
                    model ! []

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


decoder =
    JD.map2 (\state players -> { state = state, players = players })
        (field "state" JD.string)
        (field "players" (JD.list Player.decoder))


view : Model -> Html Msg
view model =
    case model of
        Loading ->
            div [] [ text "Loading" ]

        Init state ->
            Html.map InitMsg <| Init.view state

        Current state ->
            Html.map CurrentMsg <| Current.view state

        Finished state ->
            Html.map FinishedMsg <| Finished.view state
