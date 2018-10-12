module Follower.Current.Model exposing (..)

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
    | PlayerAbleToSpeak
    | PlayerChoosing PlayingState


type Msg
    = LoadGame JE.Value
    | PlayerCanSpeak JE.Value
    | PlayerReadyToSpeak
    | CandidatesReceived JE.Value
    | PlayerChosen JE.Value
    | ChooseCandidate String
    | PhoenixMsg (Phoenix.Socket.Msg Msg)


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , channelName : String
    , state : State
    }


decoder : JD.Decoder PlayingState
decoder =
    JD.map PlayingState
        (field "players" (JD.list Player.decoder))
