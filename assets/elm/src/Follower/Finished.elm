module Follower.Finished exposing (..)

import Html exposing (Html)
import Follower.Finished.Model exposing (..)
import Json.Encode as JE
import Views.Logo exposing (logo)


init : JE.Value -> Result String Model
init _ =
    Ok (Model [])


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []


view : Model -> Html Msg
view model =
    logo
