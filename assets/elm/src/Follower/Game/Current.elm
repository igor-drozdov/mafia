module Follower.Game.Current exposing (..)

import Player
import Html exposing (Html, div, text)
import Json.Encode as JE
import Follower.Game.Current.State exposing (State)
import Follower.Game.Model exposing (..)


init : List Player.Model -> Model
init players =
    Current (State players)


type Msg
    = NoOp
    | Agree JE.Value


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
