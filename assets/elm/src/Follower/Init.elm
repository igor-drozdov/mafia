module Follower.Init exposing (..)

import Html exposing (Html, div, text, button, img)
import Html.Attributes exposing (src)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Follower.Init.Model exposing (..)
import Views.Logo exposing (logo)
import Player


socketMessages : List ( String, JE.Value -> Msg )
socketMessages =
    [ ( "role_received", RoleReceived )
    , ( "start_game", Transition )
    ]


init : JE.Value -> Result String Model
init _ =
    Ok (Model Nothing [])


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RoleReceived raw ->
            case JD.decodeValue decoder raw of
                Ok { role, players } ->
                    { model | role = role, players = players } ! []

                Err error ->
                    model ! []

        _ ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view { role, players } =
    case role of
        Nothing ->
            div []
                [ logo
                , div [] [ text "Waiting other players to connect..." ]
                ]

        Just role ->
            div []
                [ div [] [ text ("You are " ++ role) ]
                , img [ src ("/images/" ++ role ++ ".jpg") ] []
                , displayOthers players
                ]


displayOthers : List Player.Model -> Html Msg
displayOthers players =
    case players of
        [] ->
            div [] []

        mafias ->
            div []
                [ div []
                    [ text ("Other players, who are also mafia: " ++ (String.join ", " <| List.map .name mafias))
                    ]
                ]
