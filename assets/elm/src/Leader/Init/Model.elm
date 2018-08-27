module Leader.Init.Model exposing (..)

import Player
import Array exposing (Array, fromList)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Phoenix.Socket


type alias WaitState =
    { players : Array Player.Model
    , total : Int
    }


type State
    = Loading
    | Wait WaitState


type Msg
    = FollowerJoined JE.Value
    | RolesAssigned JE.Value
    | LoadGame JE.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | Transition JE.Value


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , state : State
    }


decoder : JD.Decoder State
decoder =
    JD.map Wait <|
        JD.map2 WaitState
            (field "players" (JD.array Player.decoder))
            (field "total" (JD.int))


decode : JD.Value -> Model -> Model
decode raw model =
    case JD.decodeValue decoder raw of
        Ok state ->
            { model | state = state }

        Err error ->
            model
