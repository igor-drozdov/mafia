port module Ports.DeviceOrientation exposing (..)

import Json.Decode as JD exposing (field)
import Json.Encode as JE


port listener : (JE.Value -> msg) -> Sub msg


type alias Orientation =
    { alpha : Int
    , beta : Int
    , gamma : Int
    }


decoder : JD.Decoder Orientation
decoder =
    JD.map3 Orientation
        (JD.map floor (field "alpha" JD.float))
        (JD.map floor (field "beta" JD.float))
        (JD.map floor (field "gamma" JD.float))


decode : JE.Value -> Result String Orientation
decode =
    JD.decodeValue decoder


listen : (Result String Orientation -> msg) -> Sub msg
listen msg =
    listener (decode >> msg)
