module Leader.Game.Current.State exposing (..)

import Player
import Array exposing (Array)
import Json.Decode as JD exposing (field)


type alias State =
    { players : Array Player.Model }


decoder =
    JD.map State
        (field "players" (JD.array Player.decoder))
