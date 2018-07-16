module Follower.Game.Model exposing (..)

import Follower.Game.Init.State as InitState
import Follower.Game.Current.State as CurrentState
import Follower.Game.Finished.State as FinishedState


type Model
    = Loading
    | Init InitState.State
    | Current CurrentState.State
    | Finished FinishedState.State
