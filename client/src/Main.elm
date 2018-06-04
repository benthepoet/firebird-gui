import Html
import WebSocket

main =
    Html.program 
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }

socketServer =
    "wss://echo.websocket.org"

type ConnectionState 
    = Closed 
    | Open 
    | Pending

type Msg 
    = ConnectionOpen 
    | ConnectionClosed 
    | Query QueryResult
    | SocketMessage String

type QueryResult 
    = EmptySet 
    | RowSet List String 

type alias ConnectionSettings =
    { host : String
    , database : String
    , user : String
    , password : String
    }

type alias Model =
    { connectionSettings : ConnectionSettings
    , connectionState : ConnectionState
    , queryResult : QueryResult
    }
    

init =
    let
        connectionSettings = ConnectionSettings "" "" "" ""
    in
        ( Model connectionSettings Pending EmptySEt
        , Cmd.none
        )
    
update msg =
    case msg of
        ConnectionOpen ->
            ( { model | connectionState = Open }
            , Cmd.none 
            )
            
        ConnectionClosed ->
            ( { model | connectionState = Closed }
            , Cmd.none
            )
            
        Query queryResult ->
            ( { model | queryResult = queryResult }
            , Cmd.none
            )
            
        SocketMessage message ->
            ( model, Cmd.none )
            
view model =
    Html.div [] 
        [ Html.form 
            [ Html.class "pure-form pure-form-stacked"
            ]
            [ Html.fieldset [ Html.class "pure-group" ] 
                [ Html.input [] []
                , Html.input [] []
                , Html.input [] []
                , Html.input [] []
                ]
            ]
        ]
            
subscriptions model =
    WebSocket.listen socketServer SocketMessage