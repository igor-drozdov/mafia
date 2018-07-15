module Player exposing (..)

import Json.Decode as JD exposing (field)


type alias Model =
    { id : String
    , name : String
    , state : State
    }


type State
    = Init
    | Ready
    | Current
    | Finished


decoder : JD.Decoder Model
decoder =
    JD.map3 buildModel
        (field "id" JD.string)
        (field "name" JD.string)
        (field "state" JD.string)


buildModel id name state =
    Model id name (toState state)


toState state =
    case state of
        "ready" ->
            Ready

        "current" ->
            Current

        "finished" ->
            Finished

        _ ->
            Init
