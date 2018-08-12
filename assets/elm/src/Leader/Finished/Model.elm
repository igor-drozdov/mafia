module Leader.Finished.Model exposing (..)

import Player


type alias Model =
    { players : List Player.Model }


type Msg
    = NoOp
