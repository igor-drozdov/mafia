module Leader.Model exposing (..)

import Leader.Init.State as InitState
import Leader.Current.State as CurrentState
import Leader.Finished.State as FinishedState


type Model
    = Init InitState.State
    | Current CurrentState.State
    | Finished FinishedState.State
