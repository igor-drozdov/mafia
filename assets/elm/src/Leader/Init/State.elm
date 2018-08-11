module Leader.Init.State exposing (..)

import Player
import Array exposing (Array, fromList)
import Json.Decode as JD exposing (field)
import Phoenix.Socket
import Leader.Init.Msg exposing (Msg)


type alias BackendState =
    { players : Array Player.Model
    , total : Int
    }


type alias WithSocket a =
    { a | phxSocket : Phoenix.Socket.Socket Msg }


type alias State =
    WithSocket BackendState


init : Phoenix.Socket.Socket Msg -> State
init phxSocket =
    { players = fromList []
    , total = 0
    , phxSocket = phxSocket
    }


decoder : JD.Decoder BackendState
decoder =
    JD.map2 BackendState
        (field "players" (JD.array Player.decoder))
        (field "total" (JD.int))


decode : JD.Value -> State -> State
decode raw model =
    case JD.decodeValue decoder raw of
        Ok state ->
            { model | total = state.total, players = state.players }

        Err error ->
            model
