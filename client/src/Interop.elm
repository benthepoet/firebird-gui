port module Interop exposing (..)

import Json.Decode as Decode

-- PORTS


port codeChange : (String -> msg) -> Sub msg
port initCodeEditor : String -> Cmd msg