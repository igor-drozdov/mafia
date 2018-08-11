module Leader exposing (..)

--where

import Html exposing (Html)
import Platform.Cmd
import Leader.Init as Init
import Leader.Current as Current
import Leader.Finished as Finished
import Leader.Init.State as InitState
import Leader.Current.State as CurrentState
import Leader.Finished.State as FinishedState
import Leader.Model exposing (..)


-- MAIN


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Flags =
    { gameId : String
    , state : String
    }


init : Flags -> ( Model, Cmd Msg )
init { gameId, state } =
    case state of
        "current" ->
            let
                ( model, subMsg ) =
                    Current.init gameId
            in
                ( model, Cmd.map CurrentMsg subMsg )

        "finished" ->
            let
                ( model, subMsg ) =
                    Finished.init gameId
            in
                ( model, Cmd.map FinishedMsg subMsg )

        _ ->
            let
                ( model, subMsg ) =
                    Init.init gameId
            in
                ( model, Cmd.map InitMsg subMsg )



-- MODEL


type Msg
    = InitMsg Init.Msg
    | CurrentMsg Current.Msg
    | FinishedMsg Finished.Msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( InitMsg m, Init state ) ->
            let
                ( newModel, subCmd ) =
                    Init.update m state
            in
                newModel
                    ! [ Cmd.map InitMsg subCmd ]

        ( CurrentMsg m, Current state ) ->
            let
                ( newModel, subCmd ) =
                    Current.update m state
            in
                newModel
                    ! [ Cmd.map CurrentMsg subCmd ]

        ( FinishedMsg m, Finished state ) ->
            let
                ( newModel, subCmd ) =
                    Finished.update m state
            in
                newModel
                    ! [ Cmd.map FinishedMsg subCmd ]

        _ ->
            model ! []



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Init state ->
            Html.map InitMsg <| Init.view state

        Current state ->
            Html.map CurrentMsg <| Current.view state

        Finished state ->
            Html.map FinishedMsg <| Finished.view state
