import Debug
import Interop
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Msg exposing (Msg)
import Regex
import Rpc
import Task
import WebSocket


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


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


updateDatabase : Rpc.ConnectionSettings -> String -> Rpc.ConnectionSettings
updateDatabase settings database =
    { settings | database = database }


updateHost : Rpc.ConnectionSettings -> String -> Rpc.ConnectionSettings
updateHost settings host =
    { settings | host = host }


updatePassword : Rpc.ConnectionSettings -> String -> Rpc.ConnectionSettings    
updatePassword settings password =
    { settings | password = password }

    
updateUser : Rpc.ConnectionSettings -> String -> Rpc.ConnectionSettings
updateUser settings user =
    { settings | user = user }


socketProtocol : String -> String
socketProtocol = 
    Regex.replace Regex.All (Regex.regex "http") (\_ -> "ws") 


init : Flags -> ( Model, Cmd Msg )
init { hostname, protocol } =
    let
        connectionSettings = Rpc.ConnectionSettings "" "" "" ""
        query = Rpc.Query ""
        socketServer = 
            "//" ++ hostname ++ "/ws" 
                |> (++) (socketProtocol protocol)
    in
        ( Model connectionSettings Closed [] query [] socketServer
        , WebSocket.send socketServer 
            <| Rpc.request Rpc.GetConnectionState
        )
    
    
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.Connected ->
            ( { model | connectionState = Open }
            , Task.perform (\_ -> Msg.InitCodeEditor) <| Task.succeed True
            )
            
        Msg.Disconnected ->
            ( { model | connectionState = Closed }
            , Cmd.none
            )
            
        Msg.QueryResult queryResult ->
            ( { model | queryResult = queryResult }
            , Cmd.none
            )
            
        Msg.InitCodeEditor ->
            ( model
            , Interop.initCodeEditor model.query.sql
            )
            
        Msg.RpcError error ->
            ( { model | errors = Debug.log "error" [error] }
            , Cmd.none
            )
        
        Msg.SubmitConnect ->
            let
                { connectionSettings } = model
            in
                ( model
                , WebSocket.send model.socketServer 
                    <| Rpc.request 
                    <| Rpc.AttachDatabase connectionSettings
                )
                
        Msg.SubmitDisconnect ->
            ( model
            , WebSocket.send model.socketServer
                <| Rpc.request Rpc.DetachDatabase
            )
            
        Msg.SubmitQuery ->
            ( { model | queryResult = [] }
            , WebSocket.send model.socketServer
                <| Rpc.request 
                <| Rpc.ExecuteSql model.query
            )
            
        Msg.TypeDatabase database ->
            let
                connectionSettings = 
                    updateDatabase model.connectionSettings database
            in
                ( { model | connectionSettings = connectionSettings } 
                , Cmd.none
                )
            
        Msg.TypeHost host ->
            let
                connectionSettings = 
                    updateHost model.connectionSettings host
            in
                ( { model | connectionSettings = connectionSettings } 
                , Cmd.none
                )
            
        Msg.TypePassword password ->
            let
                connectionSettings = 
                    updatePassword model.connectionSettings password
            in
                ( { model | connectionSettings = connectionSettings } 
                , Cmd.none
                )
                
        Msg.TypeQuery sql ->
            ( { model | query = Rpc.Query sql }
            , Cmd.none
            )
            
        Msg.TypeUser user ->
            let
                connectionSettings = 
                    updateUser model.connectionSettings user
            in
                ( { model | connectionSettings = connectionSettings } 
                , Cmd.none
                )


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.div [ Attributes.class "header row" ] 
            [ Html.h2 [] [ Html.text "Firebird Admin" ] ]
        , Html.div [ Attributes.class "container" ]
            <| (::) (viewErrors model.errors)
            <| case model.connectionState of
                Closed ->
                    viewDisconnected model.connectionSettings
                
                Open ->
                    viewConnected model
        ]

viewConnected model =
    [ Html.div []
        [ Html.form 
            [ Events.onSubmit Msg.SubmitQuery ]
            [ Html.div 
                [ Attributes.id "code-editor" ] []
            , Html.button
                [ Attributes.type_ "button"
                , Events.onClick Msg.SubmitDisconnect
                ]
                [ Html.text "Disconnect" ]
            , Html.button 
                [ Attributes.class "primary"
                , Attributes.type_ "submit"
                ]
                [ Html.text "Execute" ]
            ]
        , Html.table []
            [ Html.tbody []
                <| viewQueryResult model.queryResult
            ]
        ]
    ]


viewDisconnected connectionSettings =
    [ Html.div [ Attributes.class "col-sm-4" ] []
    , Html.div [ Attributes.class "col-sm-4" ] 
        [ Html.form 
            [ Events.onSubmit Msg.SubmitConnect ]
            [ textInput "Host" connectionSettings.host Msg.TypeHost
            , textInput "Database" connectionSettings.database Msg.TypeDatabase
            , textInput "User" connectionSettings.user Msg.TypeUser
            , passwordInput "Password" connectionSettings.password Msg.TypePassword
            , Html.button 
                [ Attributes.class "primary" 
                , Attributes.type_ "submit"
                ] 
                [ Html.text "Connect" ]
            ]
        ]
    , Html.div [ Attributes.class "col-sm-4" ] []
    ]


viewError error =
    Html.div [ Attributes.class "card error fluid" ]
        [ Html.div [ Attributes.class "section" ]
            [ Html.h6 [] [ Html.text error ] ]
        ]


viewErrors errors =
    Html.div 
        [ Attributes.id "errors" ]
        <| case List.isEmpty errors of
            True ->
                []
                
            False ->
                List.map viewError errors


viewQueryResult =
    List.map (\row -> Html.tr [] <| viewQueryResultRow row)


viewQueryResultRow =
    List.map (\value -> Html.td [] [ Html.text value ])


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch 
        [ WebSocket.listen model.socketServer Rpc.decodeMessage
        , Interop.codeChange Msg.TypeQuery
        ]


formInput : String -> String -> String -> (String -> Msg) -> Html Msg
formInput type_ placeholder value msg =
    Html.input 
        [ Attributes.placeholder placeholder
        , Attributes.type_ type_
        , Attributes.value value
        , Events.onInput msg
        ] []


passwordInput : String -> String -> (String -> Msg) -> Html Msg
passwordInput =
    formInput "password"


textInput : String -> String -> (String -> Msg) -> Html.Html Msg
textInput =
    formInput "text"
