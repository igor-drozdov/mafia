module Leader.Current.Model exposing (..)

import Player
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Phoenix.Socket
import Time exposing (Time)


type alias PlayingState =
    { players : List Player.Model
    }


type alias PlayerSpeakingState =
    { player : Player.Model
    , elapsed : Int
    }


type State
    = Loading
    | Playing PlayingState
    | CityAwaken PlayingState
    | PlayerSpeaking PlayerSpeakingState
    | PlayerAbleToSpeak Player.Model
    | PlayerChoosing Player.Model


type Msg
    = AudioReceived JE.Value
    | CityWakes JE.Value
    | LoadGame JE.Value
    | PlayerSpeaks JE.Value
    | PlayerCanSpeak JE.Value
    | PlayerChooses JE.Value
    | SelectionBegins JE.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | Transition JE.Value
    | Tick Time


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , state : State
    }


decoder : JD.Decoder PlayingState
decoder =
    JD.map PlayingState
        (field "players" (JD.list Player.decoder))


playerSpeakingDecoder : JD.Decoder PlayerSpeakingState
playerSpeakingDecoder =
    JD.map2 PlayerSpeakingState
        (field "player" Player.decoder)
        (field "elapsed" JD.int)


playerDecoder : JD.Decoder Player.Model
playerDecoder =
    field "player" Player.decoder
