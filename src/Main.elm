port module Main exposing (..)

import Browser
import Css exposing (..)
import Html.Styled as Html exposing (Attribute, Html)
import Html.Styled.Attributes as Attributes exposing (css)
import Html.Styled.Events as Events
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


port clickedPlay : () -> Cmd msg


port clickedPause : () -> Cmd msg


main =
    Browser.element
        { init = init
        , update = update
        , view = view >> Html.toUnstyled
        , subscriptions = subscriptions
        }


type alias Model =
    { state : State }


type State
    = Prelude
    | InGolem GolemModel


type alias GolemModel =
    { currentSong : Int
    , playerState : PlayerState
    }


type PlayerState
    = Playing
    | Paused


type Msg
    = NoOp
    | Start
    | PlayerAction PlayerAction
    | ReceivedPlayerEvent PlayerEvent


type PlayerEvent
    = PlayerPaused
    | PlayerStarted
    | PlayerTrackEnded


type PlayerAction
    = PauseAction
    | PlayAction


init : () -> ( Model, Cmd Msg )
init flags =
    ( { state = Prelude }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Start ->
            ( { model | state = InGolem { currentSong = 0, playerState = Playing } }
            , clickedPlay ()
            )

        PlayerAction PlayAction ->
            ( model, clickedPlay () )

        PlayerAction PauseAction ->
            ( model, clickedPause () )

        ReceivedPlayerEvent event ->
            case model.state of
                Prelude ->
                    ( model, Cmd.none )

                InGolem golemState ->
                    let
                        ( newGolemState, cmd ) =
                            updateGolemState golemState event
                    in
                    ( { model | state = InGolem newGolemState }, cmd )


updateGolemState : GolemModel -> PlayerEvent -> ( GolemModel, Cmd Msg )
updateGolemState golemModel event =
    case event of
        PlayerPaused ->
            ( { golemModel | playerState = Paused }, Cmd.none )

        PlayerStarted ->
            ( { golemModel | playerState = Playing }, Cmd.none )

        PlayerTrackEnded ->
            ( { golemModel | currentSong = golemModel.currentSong + 1 }, clickedPlay () )


view : Model -> Html Msg
view model =
    let
        internal =
            case model.state of
                Prelude ->
                    Html.div
                        [ Events.onClick Start
                        , css [ cursor pointer ]
                        ]
                        [ Html.text "enter the golem" ]

                InGolem { currentSong, playerState } ->
                    Html.div
                        [ css
                            [ displayFlex
                            , flexDirection column
                            , alignItems center
                            ]
                        ]
                        [ Html.img
                            [ css [ width (px 600) ]
                            , Attributes.src (imageSrc currentSong)
                            ]
                            []
                        , playButton playerState
                        ]
    in
    Html.div
        [ css
            [ color palette.white
            , displayFlex
            , justifyContent center
            , alignItems center
            ]
        ]
        [ Html.node "audio"
            [ Attributes.src (audioSrc model)
            , Events.on "play" (Decode.succeed (ReceivedPlayerEvent PlayerStarted))
            , Events.on "pause" (Decode.succeed (ReceivedPlayerEvent PlayerPaused))
            , Events.on "ended" (Decode.succeed (ReceivedPlayerEvent PlayerTrackEnded))
            ]
            []
        , internal
        ]


playButton : PlayerState -> Html Msg
playButton state =
    let
        attrs handler =
            [ Events.onClick handler
            , Attributes.tabindex 0
            , css
                [ cursor pointer
                , property "width" "fit-content"
                , fontSize (px 24)
                ]
            ]
    in
    case state of
        Playing ->
            Html.div
                (attrs (PlayerAction PauseAction))
                [ Html.text "⏸" ]

        Paused ->
            Html.div
                (attrs (PlayerAction PlayAction))
                [ Html.text "⏵" ]


palette =
    { white = rgb 203 172 139
    }


imageSrc : Int -> String
imageSrc currentSong =
    "static/images/" ++ String.fromInt (currentSong + 1) ++ ".jpg"


audioSrc : Model -> String
audioSrc model =
    let
        current =
            case model.state of
                Prelude ->
                    1

                InGolem { currentSong } ->
                    currentSong + 1
    in
    "static/songs/" ++ String.fromInt current ++ ".mp3"


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch []
