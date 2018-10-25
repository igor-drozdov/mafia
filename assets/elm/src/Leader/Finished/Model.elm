module Leader.Finished.Model exposing (FinishingState, Model(..), Msg(..), decoder)

import Json.Decode as JD exposing (field)


type Msg
    = NoOp


type alias FinishingState =
    { state : String
    }


type Model
    = Finishing FinishingState


decoder : JD.Decoder FinishingState
decoder =
    JD.map FinishingState
        (field "state" JD.string)
