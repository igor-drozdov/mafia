module Leader exposing (..)

--where

import Html exposing (Html)
import Platform.Cmd
import Phoenix.Socket
import Phoenix.Channel
import Leader.Game as Game
import Leader.Game.Init as Init
import Leader.Game.Current as Current


-- MAIN


type alias Flags =
    { gameId : String
    }


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- CONSTANTS


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"



-- MODEL


type Msg
    = GameMsg Game.Msg
    | PhoenixMsg (Phoenix.Socket.Msg Msg)


type alias Model =
    { game : Game.Model
    , phxSocket : Phoenix.Socket.Socket Msg
    }


init : Flags -> ( Model, Cmd Msg )
init { gameId } =
    let
        channel =
            Phoenix.Channel.init ("rooms:leader:" ++ gameId)
                |> Phoenix.Channel.onJoin (Game.LoadGame >> GameMsg)

        initPhxSocket =
            Phoenix.Socket.init socketServer
                |> Phoenix.Socket.withDebug

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel initPhxSocket

        phxSocketWithListener : Phoenix.Socket.Socket Msg
        phxSocketWithListener =
            phxSocket
                |> Phoenix.Socket.on "follower_joined" ("rooms:leader:" ++ gameId) (Init.FollowerJoined >> Game.InitMsg >> GameMsg)
                |> Phoenix.Socket.on "follower_left" ("rooms:leader:" ++ gameId) (Current.Agree >> Game.CurrentMsg >> GameMsg)

        initModel : Model
        initModel =
            { game = Game.init
            , phxSocket = phxSocketWithListener
            }
    in
        ( initModel
        , Cmd.map PhoenixMsg phxCmd
        )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        GameMsg m ->
            let
                ( subMdl, subMsg ) =
                    Game.update m model.game
            in
                { model | game = subMdl }
                    ! [ Cmd.map GameMsg subMsg ]



-- VIEW


view : Model -> Html Msg
view model =
    Html.map GameMsg <| Game.view model.game
