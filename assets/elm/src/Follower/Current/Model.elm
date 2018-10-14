module Follower.Current.Model exposing (..)

import Player
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Ports.DeviceOrientation exposing (Orientation)


type alias PlayingState =
    { players : List Player.Model
    }


type Model
    = Playing PlayingState
    | PlayerAbleToSpeak PlayingState
    | PlayerChoosing PlayingState


type Msg
    = PlayerCanSpeak JE.Value
    | PlayerReadyToSpeak
    | DeviceOrientationChanged (Result String Orientation)
    | CandidatesReceived JE.Value
    | PlayerChosen JE.Value
    | ChooseCandidate String
    | PushSocket String JE.Value


decoder : JD.Decoder PlayingState
decoder =
    JD.map PlayingState
        (field "players" (JD.list Player.decoder))
