module Follower.Game.Init exposing (..)

import Player
import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Follower.Game.Init.State exposing (State)
import Follower.Game.Model exposing (..)


init : List Player.Model -> Model
init players =
    Init (State players)


type Msg
    = Play


update : Msg -> State -> ( Model, Cmd Msg )
update msg state =
    case msg of
        Play ->
            Current state ! []


view : State -> Html Msg
view { players } =
    div []
        [ button [ onClick Play ] [ text "Play" ]
        ]
