import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
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
    { database : String
    , host : String
    , password : String
    , user : String
    }


type alias Model =
    { connectionSettings : ConnectionSettings
    , connectionState : ConnectionState
    , queryResult : QueryResult
    }


updateDatabase : ConnectionSettings -> String -> ConnectionSettings
updateDatabase settings database =
    { settings | database = database }


updateHost : ConnectionSettings -> String -> ConnectionSettings
updateHost settings host =
    { settings | host = host }


updatePassword : ConnectionSettings -> String -> ConnectionSettings    
updatePassword settings password =
    { settings | password = password }

    
updateUser : ConnectionSettings -> String -> ConnectionSettings
updateUser settings user =
    { settings | user = user }


init : ( Model, Cmd Msg )
init =
    let
        connectionSettings = ConnectionSettings "" "" "" ""
    in
        ( Model connectionSettings Pending EmptySet
        , Cmd.none
        )
    
    
update : Msg -> Model -> ( Model, Cmd Msg )
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
            let
                connectionSettings = updateDatabase model.connectionSettings database
            in
                ( { model | connectionSettings = connectionSettings } 
                , Cmd.none
                )
            
        TypeHost host ->
            let
                connectionSettings = updateHost model.connectionSettings host
            in
                ( { model | connectionSettings = connectionSettings } 
                , Cmd.none
                )
            
        TypePassword password ->
            let
                connectionSettings = updatePassword model.connectionSettings password
            in
                ( { model | connectionSettings = connectionSettings } 
                , Cmd.none
                )
            
        TypeUser user ->
            let
                connectionSettings = updateUser model.connectionSettings user
            in
                ( { model | connectionSettings = connectionSettings } 
                , Cmd.none
                )


view : Model -> Html Msg
view model =
    Html.div [ Attributes.class "pure-g" ]
        [ Html.div [ Attributes.class "pure-u-1-3" ] []
        , Html.div [ Attributes.class "pure-u-1-3" ] 
            [ Html.form 
                [ Attributes.class "pure-form pure-form-stacked" 
                , Events.onSubmit SubmitConnect
                ]
                [ Html.fieldset [ Attributes.class "pure-group" ] 
                    [ textInput "Host" model.connectionSettings.host TypeHost
                    , textInput "Database" model.connectionSettings.database TypeDatabase
                    , textInput "User" model.connectionSettings.user TypeUser
                    , passwordInput "Password" model.connectionSettings.password TypePassword
                    ]
                , Html.button 
                    [ Attributes.class "pure-button pure-button-primary" ] 
                    [ Html.text "Connect" ]
                ]
            ]
        , Html.div [ Attributes.class "pure-u-1-3" ] []
        ]
           

subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen socketServer SocketMessage


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
