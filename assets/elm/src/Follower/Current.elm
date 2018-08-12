module Follower.Current exposing (..)

import Html exposing (Html, div, text)
import Array exposing (fromList)
import Json.Decode as JD exposing (field)
import Follower.Current.Model exposing (..)


init : String -> ( Model, Cmd Msg )
init gameId =
    Model (fromList []) ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Agree raw ->
            model ! []

        NoOp ->
            model ! []


view : Model -> Html Msg
view model =
    div [] []
