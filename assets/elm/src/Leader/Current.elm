module Leader.Current exposing (..)

import Player
import Html exposing (Html, div, text)
import Json.Encode as JE
import Json.Decode as JD exposing (field)
import Leader.Current.State exposing (State)
import Leader exposing (Model)


type Msg
    = NoOp
    | Agree JE.Value


init : String -> Model
init gameId =
    Current (State [])


update : Msg -> State -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Agree raw ->
            Current model ! []

        NoOp ->
            Current model ! []


view : State -> Html Msg
view model =
    div [] []


decode raw defaultModel =
    case JD.decodeValue Leader.Current.State.decoder raw of
        Ok state ->
            Current state

        Err error ->
            defaultModel
