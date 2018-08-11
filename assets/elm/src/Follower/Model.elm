module Follower.Model exposing (..)

import Follower.Init.State as InitState
import Follower.Current.State as CurrentState
import Follower.Finished.State as FinishedState


type Model
    = Init InitState.State
    | Current CurrentState.State
    | Finished FinishedState.State
