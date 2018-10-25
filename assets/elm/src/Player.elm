module Player exposing (Model, decoder)

import Json.Decode as JD exposing (field)


type alias Model =
    { id : String
    , name : String
    }


decoder : JD.Decoder Model
decoder =
    JD.map2 Model
        (field "id" JD.string)
        (field "name" JD.string)
