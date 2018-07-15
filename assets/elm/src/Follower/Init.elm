module Follower.Init exposing (..)

import Player
import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Phoenix.Socket


type alias Model =
    { players : List Player.Model }


init : Model
init =
    Model []


type Msg
    = Play
    | FollowerJoined JE.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Play ->
            model ! []

        FollowerJoined raw ->
            model ! []


view : Model -> Html Msg
view { players } =
    div []
        [ div [] (List.map viewPlayer players)
        , button [ onClick Play ] [ text "Play " ]
        ]


viewPlayer : Player.Model -> Html Msg
viewPlayer player =
    div [] [ text player.name ]
