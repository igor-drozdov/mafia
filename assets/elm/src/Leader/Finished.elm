module Leader.Finished exposing (init, subscriptions, update, view)

import Html exposing (Html, div, img, text)
import Html.Attributes exposing (class, id, src, style)
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Leader.Finished.Model exposing (..)
import Views.Logo exposing (logo)


init : JE.Value -> Result JD.Error Model
init raw =
    Result.map Finishing (JD.decodeValue decoder raw)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
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
        Finishing { state } ->
            case state of
                "innocents" ->
                    div [] [ logo, text "Innocents win" ]

                "mafia" ->
                    div [ id "mafia-wins", class "margin-top" ]
                        [ img [ src "/images/mafia-wins.gif", style "width" "70%" ] []
                        ]

                _ ->
                    div [] [ logo, text "Somebody else wins" ]
