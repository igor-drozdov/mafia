module Leader.Init exposing (init, socketMessages, subscriptions, update, view, viewPlayer)

import Array exposing (Array, fromList)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (id)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Leader.Init.Model exposing (..)
import List.Extra exposing (find)
import Player
import Ports.Audio exposing (playAudio)
import Views.Logo exposing (animatedLogo, logo)


socketMessages : List ( String, JE.Value -> Msg )
socketMessages =
    [ ( "follower_joined", FollowerJoined )
    , ( "roles_assigned", RolesAssigned )
    , ( "start_game", Transition )
    ]


init : JE.Value -> Result JD.Error Model
init raw =
    JD.decodeValue decoder raw


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( RolesAssigned raw, _ ) ->
            ( model
            , playAudio raw
            )

        ( FollowerJoined raw, Wait state ) ->
            case JD.decodeValue Player.decoder raw of
                Ok player ->
                    let
                        foundModel =
                            find (\p -> p.id == player.id) (Array.toList state.players)

                        newState =
                            Wait { state | players = Array.push player state.players }
                    in
                    case foundModel of
                        Just _ ->
                            ( model
                            , Cmd.none
                            )

                        Nothing ->
                            ( newState
                            , Cmd.none
                            )

                Err error ->
                    ( model
                    , Cmd.none
                    )

        _ ->
            ( model
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    case model of
        Wait { total, players } ->
            div [ id "players" ]
                [ animatedLogo
                , div [] [ text ("Waiting for " ++ String.fromInt total ++ " players to connect...") ]
                , div [] (List.map (viewPlayer players) (List.range 0 (total - 1)))
                ]


viewPlayer : Array Player.Model -> Int -> Html Msg
viewPlayer players position =
    case Array.get position players of
        Just player ->
            div [] [ text (player.name ++ " has joined the game") ]

        Nothing ->
            div [] [ text "Wait for a user" ]
