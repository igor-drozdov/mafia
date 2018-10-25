module Follower.Current.Model exposing (Model(..), Msg(..), PlayingState, decoder)

import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Player
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
    | DeviceOrientationChanged (Result JD.Error Orientation)
    | CandidatesReceived JE.Value
    | PlayerChosen JE.Value
    | ChooseCandidate String
    | PushSocket String JE.Value


decoder : JD.Decoder PlayingState
decoder =
    JD.map PlayingState
        (field "players" (JD.list Player.decoder))
