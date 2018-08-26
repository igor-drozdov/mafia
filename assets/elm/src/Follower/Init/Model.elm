module Follower.Init.Model exposing (..)

import Json.Encode as JE
import Phoenix.Socket


type alias State =
    { role : Maybe String
    }


type Msg
    = LoadGame JE.Value
    | RoleReceived JE.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)


type alias WithSocket a =
    { a | phxSocket : Phoenix.Socket.Socket Msg }


type alias Model =
    WithSocket State
