import Interop
import Html exposing (Html)
import Model exposing (Model)
import Msg exposing (Msg)
import Regex
import Rpc
import Update exposing (update)
import View exposing (view)
import WebSocket


main : Program Model.Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


socketProtocol : String -> String
socketProtocol = 
    Regex.replace Regex.All (Regex.regex "http") (\_ -> "ws") 


init : Model.Flags -> ( Model, Cmd Msg )
init { hostname, protocol } =
    let
        connectionSettings = Rpc.ConnectionSettings "" "" "" ""
        query = Rpc.Query ""
        socketServer = 
            "//" ++ hostname ++ "/ws" 
                |> (++) (socketProtocol protocol)
    in
        ( Model connectionSettings Model.Closed ["A"] [] query [] socketServer
        , WebSocket.send socketServer 
            <| Rpc.request Rpc.GetConnectionState
        )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch 
        [ WebSocket.listen model.socketServer Rpc.decodeMessage
        , Interop.codeChange Msg.TypeQuery
        ]