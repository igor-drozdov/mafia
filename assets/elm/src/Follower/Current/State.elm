module Follower.Current.State exposing (..)

import Player
import Json.Decode as JD exposing (field)
import Array exposing (Array)


type alias State =
    { players : Array Player.Model }


decoder : JD.Decoder State
decoder =
    JD.map State
        (field "players" (JD.array Player.decoder))
