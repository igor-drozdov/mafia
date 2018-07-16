module Follower.Game.Current.State exposing (..)

import Player


type alias State =
    { players : List Player.Model }
