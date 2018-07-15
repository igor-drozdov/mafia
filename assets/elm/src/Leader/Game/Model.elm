module Leader.Game.Model exposing (..)

import Leader.Game.Init.State as InitState
import Leader.Game.Current.State as CurrentState
import Leader.Game.Finished.State as FinishedState


type Model
    = Loading
    | Init InitState.State
    | Current CurrentState.State
    | Finished FinishedState.State
