module Follower.Init.Model exposing (..)

import Json.Encode as JE
import Json.Decode as JD
import Phoenix.Socket
import Player


type alias State =
    { role : Maybe String
    , players : List Player.Model
    }


type Msg
    = LoadGame JE.Value
    | RoleReceived JE.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | Transition JE.Value


type alias WithSocket a =
    { a | phxSocket : Phoenix.Socket.Socket Msg }


type alias Model =
    WithSocket State


decoder : JD.Decoder State
decoder =
    JD.map2 State
        (JD.field "role" (JD.nullable JD.string))
        (JD.field "players" (JD.list Player.decoder))
