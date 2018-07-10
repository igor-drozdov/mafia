module Leader.Init exposing (..)

import Player
import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)
import Json.Decode as JD exposing (field)
import Json.Encode as JE


type alias Model =
    { players : List Player.Model }


init : Model
init =
    Model []


type Msg
    = Play
    | FollowerJoined JE.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Play ->
            model ! []

        FollowerJoined raw ->
            let
                followerMessageDecoder =
                    JD.map Player.Model (field "name" JD.string)
            in
                case JD.decodeValue followerMessageDecoder raw of
                    Ok player ->
                        { model | players = player :: model.players } ! []

                    Err error ->
                        ( model, Cmd.none )


view : Model -> Html Msg
view { players } =
    div []
        [ div [] (List.map viewPlayer players)
        , button [ onClick Play ] [ text "Play " ]
        ]


viewPlayer : Player.Model -> Html Msg
viewPlayer player =
    div [] [ text player.name ]
