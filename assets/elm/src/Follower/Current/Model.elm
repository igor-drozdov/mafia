module Follower.Current.Model exposing (..)

import Player
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Array exposing (Array)


type alias Model =
    { players : Array Player.Model }


type Msg
    = NoOp
    | Agree JE.Value


decoder : JD.Decoder Model
decoder =
    JD.map Model
        (field "players" (JD.array Player.decoder))
