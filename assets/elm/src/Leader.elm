module Leader exposing (Flags, Model, Msg(..), State(..), decoder, init, main, subscriptions, update, view)

--where

import Browser
import Html exposing (Html)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Leader.Current as CurrentWidget
import Leader.Current.Model as Current
import Leader.Finished as FinishedWidget
import Leader.Finished.Model as Finished
import Leader.Init as InitWidget
import Leader.Init.Model as Init
import Platform.Cmd
import Ports.Socket as Socket
import Views.Logo exposing (animatedLogo)



-- MAIN


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Flags =
    { state : String
    }


init : Flags -> ( Model, Cmd Msg )
init { state } =
    let
        initChannel =
            Socket.init (LoadGame state) UnknownSocketEvent

        assignListener wrapper ( eventName, cmd ) channel =
            channel
                |> Socket.on eventName (wrapper << cmd)

        assignListeners wrapper messages channel =
            List.foldl (assignListener wrapper) channel messages

        channelWithListeners =
            initChannel
                |> assignListeners CurrentMsg CurrentWidget.socketMessages
                |> assignListeners InitMsg InitWidget.socketMessages

        joinCommand =
            Socket.join channelWithListeners
    in
    ( { channel = channelWithListeners, state = Loading }, joinCommand )



-- MODEL


type alias Model =
    { channel : Socket.Channel Msg
    , state : State
    }


type State
    = InitModel Init.Model
    | CurrentModel Current.Model
    | FinishedModel Finished.Model
    | Loading


type Msg
    = InitMsg Init.Msg
    | CurrentMsg Current.Msg
    | FinishedMsg Finished.Msg
    | LoadGame String JE.Value
    | UnknownSocketEvent String JE.Value



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        childSubscriptions =
            case model.state of
                InitModel state ->
                    Sub.map InitMsg <| InitWidget.subscriptions state

                CurrentModel state ->
                    Sub.map CurrentMsg <| CurrentWidget.subscriptions state

                FinishedModel state ->
                    Sub.map FinishedMsg <| FinishedWidget.subscriptions state

                _ ->
                    Sub.none

        mainSubscriptions =
            [ Socket.listen model.channel ]
    in
    Sub.batch (childSubscriptions :: mainSubscriptions)



-- UPDATE


decoder : JD.Decoder Flags
decoder =
    JD.map Flags
        (field "state" JD.string)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.state ) of
        ( LoadGame state raw, _ ) ->
            let
                initStateResult =
                    case state of
                        "current" ->
                            Result.map CurrentModel <| CurrentWidget.init raw

                        "finished" ->
                            Result.map FinishedModel <| FinishedWidget.init raw

                        _ ->
                            Result.map InitModel <| InitWidget.init raw
            in
            case initStateResult of
                Ok initState ->
                    ( { model | state = initState }, Cmd.none )

                Err err ->
                    ( model, Cmd.none )

        ( InitMsg (Init.Transition raw), _ ) ->
            case CurrentWidget.init raw of
                Ok state ->
                    ( { model | state = CurrentModel state }, Cmd.none )

                Err err ->
                    ( model, Cmd.none )

        ( CurrentMsg (Current.Transition raw), _ ) ->
            case FinishedWidget.init raw of
                Ok state ->
                    ( { model | state = FinishedModel state }, Cmd.none )

                Err err ->
                    ( model, Cmd.none )

        ( InitMsg m, InitModel state ) ->
            let
                ( newModel, subCmd ) =
                    InitWidget.update m state
            in
            ( { model | state = InitModel newModel }
            , Cmd.map InitMsg subCmd
            )

        ( CurrentMsg m, CurrentModel state ) ->
            let
                ( newModel, subCmd ) =
                    CurrentWidget.update m state
            in
            ( { model | state = CurrentModel newModel }
            , Cmd.map CurrentMsg subCmd
            )

        ( FinishedMsg m, FinishedModel state ) ->
            let
                ( newModel, subCmd ) =
                    FinishedWidget.update m state
            in
            ( { model | state = FinishedModel newModel }
            , Cmd.map FinishedMsg subCmd
            )

        _ ->
            ( model
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    case model.state of
        Loading ->
            animatedLogo

        InitModel state ->
            Html.map InitMsg <| InitWidget.view state

        CurrentModel state ->
            Html.map CurrentMsg <| CurrentWidget.view state

        FinishedModel state ->
            Html.map FinishedMsg <| FinishedWidget.view state
