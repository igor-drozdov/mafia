module Socket exposing (..)


type alias WithSocket a =
    { a | socketServer : String }
