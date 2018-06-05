module Msg exposing (..)

type Msg 
    = Connected
    | Disconnected 
    | QueryResult (List (List String))
    | RpcError String
    | SubmitConnect
    | TypeDatabase String
    | TypeHost String
    | TypePassword String
    | TypeUser String