module Rpc exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode


type alias ConnectionSettings =
    { database : String
    , host : String
    , password : String
    , user : String
    }


type Method 
    = AttachDatabase ConnectionSettings


type ResultCode
    = DatabaseConnected String


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
        
        
responseDecoder =
    Decode.field "code" Decode.int
        |> Decode.andThen resultDecoder
        

resultDecoder code =
    case code of
        0 ->
            Decode.map DatabaseConnected 
                <| Decode.field "result" Decode.string
            
        _ ->
            Decode.fail "Unhandled result code in response."
        
        
requestEncoder method =
    Encode.object
        (case method of
            AttachDatabase settings ->
                [ ("method", Encode.string "attach-database")
                , ("params", connectionSettingsEncoder settings)
                ]
        )