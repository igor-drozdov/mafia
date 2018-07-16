module Leader.Game.Finished exposing (..)

import Player
import Html exposing (Html, div, text)
import Json.Decode as JD exposing (field)
import Leader.Game.Finished.State exposing (State)
import Leader.Game.Model exposing (..)


decode raw defaultModel =
    case JD.decodeValue decoder raw of
        Ok state ->
            Finished state

        Err error ->
            defaultModel


decoder =
    JD.map State
        (field "players" (JD.list Player.decoder))


type Msg
    = NoOp


update : Msg -> State -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            Finished model ! []


view : State -> Html Msg
view model =
    div [] []
