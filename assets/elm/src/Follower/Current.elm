module Follower.Current exposing (..)

import Player
import Html exposing (Html, div, text)
import Json.Encode as JE


type alias Model =
    { players : List Player.Model }


init =
    Model []


type Msg
    = NoOp
    | Agree JE.Value


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
