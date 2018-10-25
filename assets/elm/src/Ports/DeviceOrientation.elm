port module Ports.DeviceOrientation exposing (Orientation, decode, decoder, listen, listener)

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
        (JD.map floor (JD.field "alpha" JD.float))
        (JD.map floor (JD.field "beta" JD.float))
        (JD.map floor (JD.field "gamma" JD.float))


decode : JE.Value -> Result JD.Error Orientation
decode =
    JD.decodeValue decoder


listen : (Result JD.Error Orientation -> msg) -> Sub msg
listen msg =
    listener (decode >> msg)
