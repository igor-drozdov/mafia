module Follower.Finished.Model exposing (Model, Msg(..))

import Player


type alias Model =
    { players : List Player.Model }


type Msg
    = NoOp
