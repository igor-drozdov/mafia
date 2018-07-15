module Leader.Game exposing (..)

import Html exposing (Html, div, text)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Player
import Leader.Game.Init as Init
import Leader.Game.Current as Current
import Leader.Game.Finished as Finished
import Leader.Game.Model exposing (..)
import Debug exposing (log)


type alias Model =
    Leader.Game.Model.Model


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
