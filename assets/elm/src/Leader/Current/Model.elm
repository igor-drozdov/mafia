module Leader.Current.Model exposing (Model(..), Msg(..), PlayerSpeakingState, PlayingState, decoder, playerDecoder, playerSpeakingDecoder)

import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Player
import Time


type alias PlayingState =
    { players : List Player.Model
    }


type alias PlayerSpeakingState =
    { player : Player.Model
    , elapsed : Int
    }


type Model
    = Playing PlayingState
    | CityAwaken PlayingState
    | PlayerSpeaking PlayerSpeakingState
    | PlayerAbleToSpeak Player.Model
    | PlayerChoosing Player.Model


type Msg
    = AudioReceived JE.Value
    | CityWakes JE.Value
    | PlayerSpeaks JE.Value
    | PlayerCanSpeak JE.Value
    | PlayerChooses JE.Value
    | SelectionBegins JE.Value
    | Transition JE.Value
    | Tick Time.Posix


decoder : JD.Decoder PlayingState
decoder =
    JD.map PlayingState
        (field "players" (JD.list Player.decoder))


playerSpeakingDecoder : JD.Decoder PlayerSpeakingState
playerSpeakingDecoder =
    JD.map2 PlayerSpeakingState
        (field "player" Player.decoder)
        (field "elapsed" JD.int)


playerDecoder : JD.Decoder Player.Model
playerDecoder =
    field "player" Player.decoder
