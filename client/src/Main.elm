import Debug
import Interop
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Model exposing (Model)
import Msg exposing (Msg)
import Regex
import Rpc
import Task
import WebSocket


main : Program Model.Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


clearErrors model =
    { model | errors = [] }


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


init : Model.Flags -> ( Model, Cmd Msg )
init { hostname, protocol } =
    let
        connectionSettings = Rpc.ConnectionSettings "" "" "" ""
        query = Rpc.Query ""
        socketServer = 
            "//" ++ hostname ++ "/ws" 
                |> (++) (socketProtocol protocol)
    in
        ( Model connectionSettings Model.Closed [] query [] socketServer
        , WebSocket.send socketServer 
            <| Rpc.request Rpc.GetConnectionState
        )
    
    
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.Connected ->
            ( { model | connectionState = Model.Open }
            , Interop.initCodeEditor model.query.sql
            )
            
        Msg.Disconnected ->
            ( { model | connectionState = Model.Closed }
            , Cmd.none
            )

        Msg.QueryResult queryResult ->
            ( { model | queryResult = queryResult }
            , Cmd.none
            )

        Msg.RpcError error ->
            ( { model | errors = Debug.log "error" [error] }
            , Cmd.none
            )

        Msg.SubmitConnect ->
            let
                { connectionSettings } = model
            in
                ( model |> clearErrors
                , WebSocket.send model.socketServer 
                    <| Rpc.request 
                    <| Rpc.AttachDatabase connectionSettings
                )

        Msg.SubmitDisconnect ->
            ( model |> clearErrors
            , WebSocket.send model.socketServer
                <| Rpc.request Rpc.DetachDatabase
            )

        Msg.SubmitQuery ->
            ( { model | queryResult = [] } |> clearErrors
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
            [ Html.div [ Attributes.class "col-sm" ] 
                [ Html.h2 [] [ Html.text "Firebird Admin" ] 
                ]
            , Html.div []
                <| case model.connectionState of
                    Model.Closed ->
                        []
                    
                    Model.Open -> 
                        [ Html.button
                            [ Attributes.type_ "button"
                            , Attributes.class "inverse"
                            , Events.onClick Msg.SubmitDisconnect
                            ]
                            [ Html.text "Disconnect" ]
                        ]
            ]
        , Html.div [ Attributes.class "container" ]
            <| (::) (viewErrors model.errors)
            <| case model.connectionState of
                Model.Closed ->
                    viewDisconnected model.connectionSettings
                
                Model.Open ->
                    viewConnected model
        ]

viewConnected model =
    [ Html.div []
        [ Html.form 
            [ Events.onSubmit Msg.SubmitQuery ]
            [ Html.div 
                [ Attributes.id "code-editor" ] []
            , Html.button 
                [ Attributes.class "primary"
                , Attributes.type_ "submit"
                ]
                [ Html.text "Execute" ]
            ]
        , Html.table []
            [ Html.thead [] []
            , Html.tbody []
                <| viewQueryResult model.queryResult
            ]
        ]
    ]


viewDisconnected connectionSettings =
    [ Html.div [ Attributes.class "row" ]
        [ Html.div [ Attributes.class "col-sm" ] []
        , Html.div [] 
            [ Html.form 
                [ Events.onSubmit Msg.SubmitConnect ]
                [ Html.fieldset [] 
                    [ Html.legend [] [ Html.text "Connection Parameters" ]
                    , inputRow "Host"
                        <| textInput "Host" connectionSettings.host Msg.TypeHost
                    , inputRow "Database" 
                        <| textInput "Database" connectionSettings.database Msg.TypeDatabase
                    , inputRow "User"
                        <| textInput "User" connectionSettings.user Msg.TypeUser
                    , inputRow "Password"
                        <| passwordInput "Password" connectionSettings.password Msg.TypePassword
                    ]
                , Html.button 
                    [ Attributes.class "primary" 
                    , Attributes.type_ "submit"
                    ] 
                    [ Html.text "Connect" ]
                ]
            ]
        , Html.div [ Attributes.class "col-sm" ] []
        ]
    ]


viewError error =
    Html.div [ Attributes.class "card animated fadeInDown error fluid" ]
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


inputRow label input =
    Html.div [ Attributes.class "row align-right" ]
        [ Html.div [ Attributes.class "col-sm-3" ] 
            [ Html.label [] [ Html.text label ] ]
        , Html.div [ Attributes.class "col-sm" ] [ input ]
        ]