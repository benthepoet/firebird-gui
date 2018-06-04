module Rpc exposing (..)

import Json.Encode as Encode


type alias ConnectionSettings =
    { database : String
    , host : String
    , password : String
    , user : String
    }


type Method 
    = AttachDatabase ConnectionSettings


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
        
        
requestEncoder method =
    Encode.object
        (case method of
            AttachDatabase settings ->
                [ ("method", Encode.string "attach-database")
                , ("params", connectionSettingsEncoder settings)
                ]
        )