module Follower.Finished exposing (..)

import Html exposing (Html, div, text)
import Array exposing (fromList)
import Json.Decode as JD exposing (field)
import Follower.Finished.Model exposing (..)
import Player


decoder =
    JD.map Model
        (field "players" (JD.list Player.decoder))


init : String -> ( Model, Cmd Msg )
init gameId =
    Model [] ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []


view : Model -> Html Msg
view model =
    div [] []
