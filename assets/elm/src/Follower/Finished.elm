module Follower.Finished exposing (..)

import Html exposing (Html)
import Follower.Finished.Model exposing (..)
import Views.Logo exposing (logo)


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
    logo
