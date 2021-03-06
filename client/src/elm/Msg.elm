module Msg exposing (..)

type Msg 
    = Connected
    | Disconnected
    | PopError
    | QueryResult (List (List String))
    | RpcError String
    | SubmitConnect
    | SubmitDisconnect
    | SubmitQuery
    | TypeDatabase String
    | TypeHost String
    | TypePassword String
    | TypeQuery String
    | TypeUser String