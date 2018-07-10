module Leader.Finished exposing (..)

import Player
import Html exposing (Html, div, text)


type alias Model =
    { players : List Player.Model }


init =
    Model []


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []


view : Model -> Html Msg
view model =
    div [] []
