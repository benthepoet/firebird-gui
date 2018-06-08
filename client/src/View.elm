module View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import Model exposing (Model)
import Msg exposing (Msg)


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
            <| (::) (viewErrors model.errors model.errorQueue)
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


viewError queue error =
    let
        attributes = 
            case List.length queue of
                0 ->
                    [ Attributes.class "card error fluid animated fadeIn" ]
                    
                _ ->
                    [ Attributes.class "card error fluid animated fadeOut"
                    , onAnimationEnd Msg.PopError
                    ]
    in
        Html.div attributes
            [ Html.div [ Attributes.class "section" ]
                [ Html.h6 [] [ Html.text error ] ]
            ]


viewErrors errors queue =
    Html.div 
        [ Attributes.id "errors" ]
        <| case List.isEmpty errors of
            True ->
                []
                
            False ->
                List.map (viewError queue) errors


viewQueryResult =
    List.map (\row -> Html.tr [] <| viewQueryResultRow row)


viewQueryResultRow =
    List.map (\value -> Html.td [] [ Html.text value ])


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


onAnimationEnd msg =
    Events.on "animationend"
        <| Decode.succeed msg