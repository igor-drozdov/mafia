port module Ports.Socket exposing (Channel, init, join, joinListenerPort, joinPort, listen, on, onListenerPort, onPort, push, pushPort)

import Dict exposing (Dict)
import Json.Encode as JE


port onPort : String -> Cmd msg


port pushPort : ( String, JE.Value ) -> Cmd msg


port onListenerPort : (( String, JE.Value ) -> msg) -> Sub msg


port joinListenerPort : (JE.Value -> msg) -> Sub msg


port joinPort : () -> Cmd msg


type alias Channel msg =
    { onJoin : JE.Value -> msg
    , onUnknownEvent : String -> JE.Value -> msg
    , onEvents : Dict String (JE.Value -> msg)
    }


init : (JE.Value -> msg) -> (String -> JE.Value -> msg) -> Channel msg
init onJoin onUnknownEvent =
    Channel onJoin onUnknownEvent Dict.empty


on : String -> (JE.Value -> msg) -> Channel msg -> Channel msg
on event msgWrapper channel =
    { channel | onEvents = Dict.insert event msgWrapper channel.onEvents }


join : Channel msg -> Cmd msg
join channel =
    Cmd.batch (joinPort () :: List.map onPort (Dict.keys channel.onEvents))


push : String -> JE.Value -> Cmd msg
push event payload =
    pushPort ( event, payload )


listen : Channel msg -> Sub msg
listen channel =
    let
        getHandler : ( String, JE.Value ) -> msg
        getHandler ( event, payload ) =
            case Dict.get event channel.onEvents of
                Just msgWrapper ->
                    msgWrapper payload

                Nothing ->
                    channel.onUnknownEvent event payload
    in
    Sub.batch
        [ joinListenerPort channel.onJoin
        , onListenerPort getHandler
        ]
