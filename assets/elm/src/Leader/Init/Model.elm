module Leader.Init.Model exposing (..)

import Player
import Array exposing (Array, fromList)
import Json.Decode as JD exposing (field)
import Json.Encode as JE


type alias WaitState =
    { players : Array Player.Model
    , total : Int
    }


type Model
    = Wait WaitState


type Msg
    = FollowerJoined JE.Value
    | RolesAssigned JE.Value
    | Transition JE.Value


decoder : JD.Decoder Model
decoder =
    JD.map Wait <|
        JD.map2 WaitState
            (field "players" (JD.array Player.decoder))
            (field "total" (JD.int))
