module Leader exposing (..)

--where

import Html exposing (Html, div, text)
import Platform.Cmd
import Phoenix.Socket
import Phoenix.Channel
import Json.Encode as JE
import Leader.Init as Init
import Leader.Current as Current
import Leader.Finished as Finished


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
    = InitMsg Init.Msg
    | CurrentMsg Current.Msg
    | FinishedMsg Finished.Msg
    | PhoenixMsg (Phoenix.Socket.Msg Msg)


type alias Model =
    { state : State
    , initModel : Init.Model
    , currentModel : Current.Model
    , finishedModel : Finished.Model
    , phxSocket : Phoenix.Socket.Socket Msg
    }


type State
    = Loading
    | Init
    | Current
    | Finished


init : Flags -> ( Model, Cmd Msg )
init { gameId } =
    let
        channel =
            Phoenix.Channel.init ("rooms:leader:" ++ gameId)
                |> Phoenix.Channel.withPayload userParams

        initPhxSocket =
            Phoenix.Socket.init socketServer
                |> Phoenix.Socket.withDebug

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel initPhxSocket

        phxSocketWithListener =
            phxSocket |> Phoenix.Socket.on "follower_joined" ("rooms:leader:" ++ gameId) Init.FollowerJoined

        initModel : Model
        initModel =
            { state = Loading
            , initModel = Init.init
            , currentModel = Current.init
            , finishedModel = Finished.init
            , phxSocket = Phoenix.Socket.map InitMsg phxSocketWithListener
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


userParams : JE.Value
userParams =
    JE.object [ ( "user_id", JE.string "123" ) ]


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

        InitMsg m ->
            let
                ( subMdl, subCmd ) =
                    Init.update m model.initModel
            in
                { model | initModel = subMdl }
                    ! [ Cmd.map InitMsg subCmd ]

        CurrentMsg m ->
            let
                ( subMdl, subCmd ) =
                    Current.update m model.currentModel
            in
                { model | currentModel = subMdl }
                    ! [ Cmd.map CurrentMsg subCmd ]

        FinishedMsg m ->
            let
                ( subMdl, subCmd ) =
                    Finished.update m model.finishedModel
            in
                { model | finishedModel = subMdl }
                    ! [ Cmd.map FinishedMsg subCmd ]



-- VIEW


view : Model -> Html Msg
view model =
    case model.state of
        Loading ->
            div [] [ text "Loading" ]

        Init ->
            Html.map InitMsg <| Init.view model.initModel

        Current ->
            Html.map CurrentMsg <| Current.view model.currentModel

        Finished ->
            Html.map FinishedMsg <| Finished.view model.finishedModel
