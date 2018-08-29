module Follower.Current.Model exposing (..)

import Player
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Phoenix.Socket


type alias PlayingState =
    { players : List Player.Model
    }


type State
    = Loading
    | Playing PlayingState


type Msg
    = LoadGame JE.Value
    | CandidatesReceived JE.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , state : State
    }


decoder : JD.Decoder State
decoder =
    JD.map (Playing << PlayingState)
        (field "players" (JD.list Player.decoder))


decode : JD.Value -> Model -> Model
decode raw model =
    case JD.decodeValue decoder raw of
        Ok state ->
            { model | state = state }

        Err error ->
            model
