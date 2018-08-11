module Follower.Init.Msg exposing (..)

import Json.Encode as JE
import Phoenix.Socket


type Msg
    = LoadGame JE.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
