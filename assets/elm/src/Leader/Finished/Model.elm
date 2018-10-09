module Leader.Finished.Model exposing (..)

import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Phoenix.Socket


type Msg
    = LoadGame JE.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)


type alias FinishingState =
    { state : String
    }


type State
    = Loading
    | Finishing FinishingState


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , state : State
    }


decoder : JD.Decoder FinishingState
decoder =
    JD.map FinishingState
        (field "state" (JD.string))
