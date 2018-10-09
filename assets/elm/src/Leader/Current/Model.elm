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
    | PlayerSpeaking Player.Model
    | PlayerChoosing Player.Model


type Msg
    = AudioReceived JE.Value
    | CityWakes JE.Value
    | LoadGame JE.Value
    | PlayerSpeaks JE.Value
    | PlayerChooses JE.Value
    | SelectionBegins JE.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | Transition JE.Value


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , state : State
    }


decoder : JD.Decoder PlayingState
decoder =
    JD.map PlayingState
        (field "players" (JD.list Player.decoder))
