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
    | NextAction
    | PrevAction


init : () -> ( Model, Cmd Msg )
init flags =
    ( { state = Prelude }
    , Cmd.none
    )


totalSongs : Int
totalSongs =
    8


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Start ->
            ( { model | state = InGolem { currentSong = 0, playerState = Playing } }
            , clickedPlay ()
            )

        PlayerAction playerAction ->
            case model.state of
                Prelude ->
                    ( model, Cmd.none )

                InGolem golemState ->
                    let
                        ( newGolemState, cmd ) =
                            updateGolemFromAction golemState playerAction
                    in
                    ( { model | state = InGolem newGolemState }, cmd )

        ReceivedPlayerEvent event ->
            case model.state of
                Prelude ->
                    ( model, Cmd.none )

                InGolem golemState ->
                    let
                        ( newGolemState, cmd ) =
                            updateGolemFromEvent golemState event
                    in
                    ( { model | state = InGolem newGolemState }, cmd )


updateGolemFromAction : GolemModel -> PlayerAction -> ( GolemModel, Cmd Msg )
updateGolemFromAction golemModel playerAction =
    case playerAction of
        PauseAction ->
            ( golemModel, clickedPause () )

        PlayAction ->
            ( golemModel, clickedPlay () )

        NextAction ->
            ( { golemModel | currentSong = min (totalSongs - 1) (golemModel.currentSong + 1) }
            , clickedPlay ()
            )

        PrevAction ->
            ( { golemModel | currentSong = max 0 (golemModel.currentSong - 1) }
            , clickedPlay ()
            )


updateGolemFromEvent : GolemModel -> PlayerEvent -> ( GolemModel, Cmd Msg )
updateGolemFromEvent golemModel event =
    case event of
        PlayerPaused ->
            ( { golemModel | playerState = Paused }, Cmd.none )

        PlayerStarted ->
            ( { golemModel | playerState = Playing }, Cmd.none )

        PlayerTrackEnded ->
            ( { golemModel | currentSong = golemModel.currentSong + 1 }
            , clickedPlay ()
            )


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
                        [ Html.div
                            [ css
                                [ width (px 600)
                                , displayFlex
                                , alignItems center
                                , justifyContent center
                                ]
                            ]
                            [ Html.img
                                [ Attributes.src (imageSrc currentSong)
                                , css [ width (pct 100) ]
                                ]
                                []
                            ]
                        , Html.div
                            [ css
                                [ displayFlex
                                , justifyContent spaceBetween
                                , width (px 200)
                                ]
                            ]
                            [ trackButton Prev
                            , playButton playerState
                            , trackButton Next
                            ]
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


type Direction
    = Next
    | Prev


trackButton : Direction -> Html Msg
trackButton direction =
    let
        ( button, msg ) =
            case direction of
                Next ->
                    ( ">", PlayerAction NextAction )

                Prev ->
                    ( "<", PlayerAction PrevAction )
    in
    Html.div
        [ css
            [ cursor pointer
            , width (px 44)
            , height (px 44)
            , displayFlex
            , alignItems center
            , justifyContent center
            ]
        , Attributes.tabindex 0
        , Events.onClick msg
        ]
        [ Html.text button ]


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
                , width (px 44)
                , height (px 44)
                , displayFlex
                , alignItems center
                , justifyContent center
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
