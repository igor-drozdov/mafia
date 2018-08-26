port module Ports.Audio exposing (..)

import Json.Decode as JD exposing (field)
import Json.Encode as JE


port play : String -> Cmd msg


playAudio : JE.Value -> Cmd msg
playAudio raw =
    case JD.decodeValue (field "audio" JD.string) raw of
        Ok audio ->
            play ("/audios/" ++ audio ++ ".mp3")

        Err error ->
            Cmd.none
