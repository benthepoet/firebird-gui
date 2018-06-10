module Model exposing (..)

import Rpc


type ConnectionState 
    = Closed 
    | Open


type alias Flags = 
    { hostname : String 
    , protocol: String
    }


type alias Model =
    { connectionSettings : Rpc.ConnectionSettings
    , connectionState : ConnectionState
    , errors : List String
    , query : Rpc.Query
    , queryResult : List (List String)
    , socketServer : String
    }