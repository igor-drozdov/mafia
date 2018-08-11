module Follower.Finished exposing (..)

import Html exposing (Html, div, text)
import Array exposing (fromList)
import Json.Decode as JD exposing (field)
import Follower.Finished.State exposing (State)
import Follower.Model exposing (..)
import Player


decoder =
    JD.map State
        (field "players" (JD.list Player.decoder))


type Msg
    = NoOp


init : String -> ( Model, Cmd Msg )
init gameId =
    Finished (State []) ! []


update : Msg -> State -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            Finished model ! []


view : State -> Html Msg
view model =
    div [] []
