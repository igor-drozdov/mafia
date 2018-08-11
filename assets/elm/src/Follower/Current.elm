module Follower.Current exposing (..)

import Html exposing (Html, div, text)
import Array exposing (fromList)
import Json.Encode as JE
import Json.Decode as JD exposing (field)
import Follower.Current.State exposing (State)
import Follower.Model exposing (..)


type Msg
    = NoOp
    | Agree JE.Value


init : String -> ( Model, Cmd Msg )
init gameId =
    Current (State (fromList [])) ! []


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
