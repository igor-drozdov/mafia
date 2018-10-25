module Follower.Finished exposing (init, update, view)

import Follower.Finished.Model exposing (..)
import Html exposing (Html)
import Json.Decode as JD
import Json.Encode as JE
import Views.Logo exposing (logo)


init : JE.Value -> Result JD.Error Model
init _ =
    Ok (Model [])


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    logo
