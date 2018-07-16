module Follower.Game.Finished exposing (..)

import Player
import Html exposing (Html, div, text)
import Follower.Game.Finished.State exposing (State)
import Follower.Game.Model exposing (..)


init : List Player.Model -> Model
init players =
    Finished (State players)


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
