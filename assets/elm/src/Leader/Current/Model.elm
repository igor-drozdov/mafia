module Leader.Current.Model exposing (..)

import Player
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Phoenix.Socket


type alias PlayingState =
    { players : List Player.Model
    }


type State
    = Loading
    | Playing PlayingState
    | CityAwaken PlayingState


type Msg
    = AudioReceived JE.Value
    | CityWakes JE.Value
    | LoadGame JE.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , state : State
    }


decoder : JD.Decoder PlayingState
decoder =
    JD.map PlayingState
        (field "players" (JD.list Player.decoder))
