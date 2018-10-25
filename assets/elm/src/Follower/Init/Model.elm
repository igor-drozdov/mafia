module Follower.Init.Model exposing (Model, Msg(..), decoder)

import Json.Decode as JD
import Json.Encode as JE
import Player


type alias Model =
    { role : Maybe String
    , players : List Player.Model
    }


type Msg
    = RoleReceived JE.Value
    | Transition JE.Value


decoder : JD.Decoder Model
decoder =
    JD.map2 Model
        (JD.field "role" (JD.nullable JD.string))
        (JD.field "players" (JD.list Player.decoder))
