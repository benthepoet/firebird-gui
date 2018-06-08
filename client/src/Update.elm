module Update exposing (update)

import Debug
import Interop
import Model exposing (Model)
import Msg exposing (Msg)
import Rpc
import WebSocket


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.Connected ->
            ( { model | connectionState = Model.Open }
            , Interop.initCodeEditor model.query.sql
            )
            
        Msg.Disconnected ->
            ( { model | connectionState = Model.Closed }
            , Cmd.none
            )
            
        Msg.PopError ->
            ( { model | errors = model.errorQueue, errorQueue = [] }
            , Cmd.none
            )

        Msg.QueryResult queryResult ->
            ( { model | queryResult = queryResult }
            , Cmd.none
            )

        Msg.RpcError error ->
            ( { model | errorQueue = Debug.log "error" [error] }
            , Cmd.none
            )

        Msg.SubmitConnect ->
            let
                { connectionSettings } = model
            in
                ( model
                , WebSocket.send model.socketServer 
                    <| Rpc.request 
                    <| Rpc.AttachDatabase connectionSettings
                )

        Msg.SubmitDisconnect ->
            ( model
            , WebSocket.send model.socketServer
                <| Rpc.request Rpc.DetachDatabase
            )

        Msg.SubmitQuery ->
            ( { model | queryResult = [] }
            , WebSocket.send model.socketServer
                <| Rpc.request 
                <| Rpc.ExecuteSql model.query
            )

        Msg.TypeDatabase database ->
            let
                connectionSettings = 
                    updateDatabase model.connectionSettings database
            in
                ( { model | connectionSettings = connectionSettings } 
                , Cmd.none
                )

        Msg.TypeHost host ->
            let
                connectionSettings = 
                    updateHost model.connectionSettings host
            in
                ( { model | connectionSettings = connectionSettings } 
                , Cmd.none
                )

        Msg.TypePassword password ->
            let
                connectionSettings = 
                    updatePassword model.connectionSettings password
            in
                ( { model | connectionSettings = connectionSettings } 
                , Cmd.none
                )
                
        Msg.TypeQuery sql ->
            ( { model | query = Rpc.Query sql }
            , Cmd.none
            )
            
        Msg.TypeUser user ->
            let
                connectionSettings = 
                    updateUser model.connectionSettings user
            in
                ( { model | connectionSettings = connectionSettings } 
                , Cmd.none
                )
                
                
clearErrors model =
    { model | errors = [] }


updateDatabase : Rpc.ConnectionSettings -> String -> Rpc.ConnectionSettings
updateDatabase settings database =
    { settings | database = database }


updateHost : Rpc.ConnectionSettings -> String -> Rpc.ConnectionSettings
updateHost settings host =
    { settings | host = host }


updatePassword : Rpc.ConnectionSettings -> String -> Rpc.ConnectionSettings    
updatePassword settings password =
    { settings | password = password }

    
updateUser : Rpc.ConnectionSettings -> String -> Rpc.ConnectionSettings
updateUser settings user =
    { settings | user = user }