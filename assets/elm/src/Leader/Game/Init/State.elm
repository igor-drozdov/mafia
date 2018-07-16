module Leader.Game.Init.State exposing (..)

import Player
import Array exposing (Array)
import Json.Decode as JD exposing (field)


type alias State =
    { players : Array Player.Model
    , total : Int
    }


decoder =
    JD.map2 State
        (field "players" (JD.array Player.decoder))
        (field "total" (JD.int))
