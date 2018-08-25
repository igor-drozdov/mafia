module Leader.Init.Model exposing (..)

import Player
import Array exposing (Array, fromList)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Phoenix.Socket
import Leader.Init.Msg exposing (Msg)


type alias State =
    { players : Array Player.Model
    , total : Int
    }


type Msg
    = FollowerJoined JE.Value
    | LoadGame JE.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | Transition JE.Value


type alias WithSocket state =
    { state | phxSocket : Phoenix.Socket.Socket Msg }


type Model
    = Loading (WithSocket {})
    | Wait (WithSocket State)


decoder : JD.Decoder State
decoder =
    JD.map2 State
        (field "players" (JD.array Player.decoder))
        (field "total" (JD.int))


decode : JD.Value -> Model -> Model
decode raw model =
    case JD.decodeValue decoder raw of
        Ok state ->
            { model | total = state.total, players = state.players }

        Err error ->
            model
