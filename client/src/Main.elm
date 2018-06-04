import Html
import Html.Attributes as Attributes
import Html.Events as Events
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
    | SubmitConnect
    | TypeDatabase String
    | TypeHost String
    | TypePassword String
    | TypeUser String

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
        ( Model connectionSettings Pending EmptySet
        , Cmd.none
        )
    
update msg model =
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
            
        SubmitConnect ->
            ( model, Cmd.none )
            
        TypeDatabase database ->
            ( model
            , Cmd.none
            )
            
        TypeHost host ->
            ( model
            , Cmd.none
            )
            
        TypePassword password ->
            ( model
            , Cmd.none
            )
            
        TypeUser user ->
            ( model
            , Cmd.none
            )

view model =
    Html.div [ Attributes.class "pure-g" ]
        [ Html.div [ Attributes.class "pure-u-1-3" ] []
        , Html.div [ Attributes.class "pure-u-1-3" ] 
            [ Html.form 
                [ Attributes.class "pure-form pure-form-stacked" 
                , Events.onSubmit SubmitConnect
                ]
                [ Html.fieldset [ Attributes.class "pure-group" ] 
                    [ Html.input [ Attributes.type_ "text" ] []
                    , Html.input [ Attributes.type_ "text" ] []
                    , Html.input [ Attributes.type_ "text" ] []
                    , Html.input [ Attributes.type_ "text" ] []
                    ]
                , Html.button 
                    [ Attributes.class "pure-button pure-button-primary" ] 
                    [ Html.text "Connect" ]
                ]
            ]
        , Html.div [ Attributes.class "pure-u-1-3" ] []
        ]
            
subscriptions model =
    WebSocket.listen socketServer SocketMessage