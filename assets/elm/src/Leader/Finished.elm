module Leader.Finished exposing (..)

import Player
import Html exposing (Html, div, text)
import Json.Decode as JD exposing (field)
import Leader.Finished.State exposing (State)


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


init : String -> Model
init gameId =
    Current (State [])


update : Msg -> State -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            Finished model ! []


view : State -> Html Msg
view model =
    div [] []
