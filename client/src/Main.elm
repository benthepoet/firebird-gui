import Debug
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Msg exposing (Msg)
import Rpc
import WebSocket


main : Program Never Model Msg
main =
    Html.program 
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


socketServer : String
socketServer =
    "ws://localhost:8920"


type ConnectionState 
    = Closed 
    | Open


type alias Model =
    { connectionSettings : Rpc.ConnectionSettings
    , connectionState : ConnectionState
    , query : Rpc.Query
    , queryResult : List (List String)
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


init : ( Model, Cmd Msg )
init =
    let
        connectionSettings = Rpc.ConnectionSettings "" "" "" ""
        query = Rpc.Query ""
    in
        ( Model connectionSettings Closed query []
        , Cmd.none
        )
    
    
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.Connected ->
            ( { model | connectionState = Open }
            , Cmd.none 
            )
            
        Msg.Disconnected ->
            ( { model | connectionState = Closed }
            , Cmd.none
            )
            
        Msg.QueryResult queryResult ->
            ( { model | queryResult = queryResult }
            , Cmd.none
            )
            
        Msg.RpcError error ->
            let
                e = Debug.log "error" error
            in
                ( model
                , Cmd.none
                )
            
        Msg.SubmitConnect ->
            let
                { connectionSettings } = model
            in
                ( model
                , WebSocket.send socketServer 
                    <| Rpc.request 
                    <| Rpc.AttachDatabase connectionSettings
                )
                
        Msg.SubmitDisconnect ->
            ( model
            , WebSocket.send socketServer
                <| Rpc.request Rpc.DetachDatabase
            )
            
        Msg.SubmitQuery ->
            ( model
            , WebSocket.send socketServer
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
    Html.div [ Attributes.class "pure-g" ]
        <| case model.connectionState of
            Closed ->
                viewDisconnected model
            
            Open ->
                viewConnected model


viewConnected model =
    [ Html.div [ Attributes.class "pure-u-1" ]
        [ Html.form 
            [ Attributes.class "pure-form"
            , Events.onSubmit Msg.SubmitQuery
            ]
            [ Html.fieldset [ Attributes.class "pure-group" ]
                [ Html.textarea 
                    [ Attributes.class "pure-u-1-1" 
                    , Events.onInput Msg.TypeQuery
                    ] 
                    [ Html.text model.query.sql ] 
                ]
            , Html.button
                [ Attributes.class "pure-button pure-button-primary button-error mr-1"
                , Attributes.type_ "button"
                , Events.onClick Msg.SubmitDisconnect
                ]
                [ Html.text "Disconnect" ]
            , Html.button 
                [ Attributes.class "pure-button pure-button-primary"
                , Attributes.type_ "submit"
                ]
                [ Html.text "Execute" ]
            ]
        ]
    ]


viewDisconnected model =
    [ Html.div [ Attributes.class "pure-u-1-3" ] []
    , Html.div [ Attributes.class "pure-u-1-3" ] 
        [ Html.form 
            [ Attributes.class "pure-form pure-form-stacked" 
            , Events.onSubmit Msg.SubmitConnect
            ]
            [ Html.fieldset [ Attributes.class "pure-group" ] 
                [ textInput "Host" model.connectionSettings.host Msg.TypeHost
                , textInput "Database" model.connectionSettings.database Msg.TypeDatabase
                , textInput "User" model.connectionSettings.user Msg.TypeUser
                , passwordInput "Password" model.connectionSettings.password Msg.TypePassword
                ]
            , Html.button 
                [ Attributes.class "pure-button pure-button-primary" 
                , Attributes.type_ "submit"
                ] 
                [ Html.text "Connect" ]
            ]
        ]
    , Html.div [ Attributes.class "pure-u-1-3" ] []
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen socketServer Rpc.decodeMessage


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
