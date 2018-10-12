port module Ports.DeviceOrientation exposing (..)

import Json.Decode as JD exposing (field)
import Json.Encode as JE


port listener : (JE.Value -> msg) -> Sub msg
