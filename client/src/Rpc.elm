module Rpc exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Msg exposing (Msg)


type alias ConnectionSettings =
    { database : String
    , host : String
    , password : String
    , user : String
    }


type alias Query =
    { sql : String
    }


type Method 
    = AttachDatabase ConnectionSettings
    | DetachDatabase
    | ExecuteSql Query


request : Method -> String
request method =
    Encode.encode 0 <| requestEncoder method


connectionSettingsEncoder settings =
    Encode.object
        [ ("database", Encode.string settings.database)
        , ("host", Encode.string settings.host)
        , ("password", Encode.string settings.password)
        , ("user", Encode.string settings.user)
        ]


queryEncoder query =
    Encode.object
        [ ("sql", Encode.string query.sql) ]


decodeMessage message =
    let
        result = 
            Decode.decodeString (Decode.oneOf [errorDecoder, responseDecoder]) message
    in 
        case result of
            Ok msg ->
                msg
                
            Err error ->
                Msg.RpcError error


errorDecoder =
    Decode.field "error"
        <| Decode.map Msg.RpcError
        <| Decode.field "message" Decode.string


responseDecoder =
    Decode.at ["result", "code"] Decode.int
        |> Decode.andThen resultDecoder
        

resultDecoder code =
    case code of
        0 ->
            Decode.succeed Msg.Connected

        1 ->
            Decode.succeed Msg.Disconnected
            
        2 ->
            Decode.map Msg.QueryResult
                <| Decode.at ["result", "data"]
                <| Decode.list (Decode.list Decode.string)
            
        _ ->
            Decode.fail "Unhandled result code in response."
        
        
requestEncoder method =
    Encode.object
        (case method of
            AttachDatabase settings ->
                [ ("method", Encode.string "attach-database")
                , ("params", connectionSettingsEncoder settings)
                ]
                
            DetachDatabase ->
                [ ("method", Encode.string "detach-database") ]
                
            ExecuteSql query ->
                [ ("method", Encode.string "execute-sql")
                , ("params", queryEncoder query)
                ]
        )