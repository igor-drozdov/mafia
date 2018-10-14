module Leader.Init exposing (..)

import Player
import Html exposing (Html, div, text, button)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Leader.Init.Model exposing (..)
import Array exposing (Array, fromList)
import List.Extra exposing (find)
import Ports.Audio exposing (playAudio)
import Views.Logo exposing (logo, animatedLogo)


socketMessages : List ( String, JE.Value -> Msg )
socketMessages =
    [ ( "follower_joined", FollowerJoined )
    , ( "roles_assigned", RolesAssigned )
    , ( "start_game", Transition )
    ]


init : JE.Value -> Result String Model
init raw =
    JD.decodeValue decoder raw


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( RolesAssigned raw, _ ) ->
            model ! [ playAudio raw ]

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
                                model ! []

                            Nothing ->
                                newState ! []

                Err error ->
                    model ! []

        _ ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    case model of
        Wait { total, players } ->
            if (Array.length players) == total then
                div [] [ logo, text "All the players joined!" ]
            else
                div []
                    [ animatedLogo
                    , div [] [ text ("Waiting for " ++ (toString total) ++ " players to connect...") ]
                    , div [] (List.map (viewPlayer players) (List.range 0 (total - 1)))
                    ]


viewPlayer : Array Player.Model -> Int -> Html Msg
viewPlayer players position =
    case Array.get position players of
        Just player ->
            div []
                [ div [] [ text (player.name ++ " has joined the game") ]
                ]

        Nothing ->
            div []
                [ div [] [ text "Wait for a user" ] ]
