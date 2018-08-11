module Leader.Init.Msg exposing (..)

import Json.Encode as JE
import Phoenix.Socket


type Msg
    = FollowerJoined JE.Value
    | LoadGame JE.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
