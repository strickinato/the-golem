port module Main exposing (..)

import Browser
import Css exposing (..)
import Dict exposing (Dict)
import Html.Styled as Html exposing (Attribute, Html)
import Html.Styled.Attributes as Attributes exposing (css)
import Html.Styled.Events as Events
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Random exposing (Generator)
import Random.Extra as Random exposing (andMap)
import Svg.Styled as Svg exposing (Svg)
import Svg.Styled.Attributes as SvgAttributes


port clickedPlay : Int -> Cmd msg


port clickedPause : () -> Cmd msg


port receivedMetadata : (Encode.Value -> msg) -> Sub msg


port receivedTimeUpdate : (Encode.Value -> msg) -> Sub msg


port receivedSongEnded : (Encode.Value -> msg) -> Sub msg


main =
    Browser.element
        { init = init
        , update = update
        , view = view >> Html.toUnstyled
        , subscriptions = subscriptions
        }


type alias Model =
    { songMetadata : Dict Int { duration : Float }
    , currentSong : Int
    , playerState : PlayerState
    , currentTime : Float
    , hasStarted : Bool
    }


type PlayerState
    = Playing
    | Paused


type Msg
    = NoOp
    | Start
    | ReceivedMetadata ( Int, Metadata )
    | ReceivedTimeUpdate Float
    | ReceivedSongEnded Int
    | PlayerAction PlayerAction


type alias Metadata =
    { duration : Float }


type PlayerAction
    = PauseAction
    | PlayAction
    | NextAction
    | PrevAction


init : () -> ( Model, Cmd Msg )
init flags =
    ( { songMetadata = Dict.empty
      , currentSong = 0
      , playerState = Paused
      , currentTime = 0
      , hasStarted = False
      }
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
            ( { model
                | playerState = Playing
                , hasStarted = True
              }
            , clickedPlay 0
            )

        ReceivedTimeUpdate currentTime ->
            ( { model | currentTime = currentTime }
            , Cmd.none
            )

        ReceivedSongEnded _ ->
            ( { model | currentSong = model.currentSong + 1, currentTime = 0 }
            , clickedPlay (model.currentSong + 1)
            )

        ReceivedMetadata ( songNumber, metaData ) ->
            ( { model | songMetadata = Dict.insert songNumber metaData model.songMetadata }
            , Cmd.none
            )

        PlayerAction playerAction ->
            updateGolemFromAction model playerAction


updateGolemFromAction : Model -> PlayerAction -> ( Model, Cmd Msg )
updateGolemFromAction model playerAction =
    case playerAction of
        PauseAction ->
            ( { model | playerState = Paused }, clickedPause () )

        PlayAction ->
            ( { model | playerState = Playing }, clickedPlay model.currentSong )

        NextAction ->
            let
                nextSong =
                    min (totalSongs - 1) (model.currentSong + 1)
            in
            ( { model | currentSong = nextSong }
            , clickedPlay nextSong
            )

        PrevAction ->
            let
                prevSong =
                    if model.currentTime > 2 then
                        model.currentSong

                    else
                        max 0 (model.currentSong - 1)
            in
            ( { model | currentSong = prevSong }
            , clickedPlay prevSong
            )


view : Model -> Html Msg
view model =
    let
        internal =
            if model.hasStarted then
                [ Html.div
                    [ css
                        [ width (px 600)
                        , displayFlex
                        , overflow hidden
                        ]
                    ]
                    ([ 0, 1, 2, 3, 4, 5, 6, 7 ]
                        |> List.map
                            (\i ->
                                let
                                    translateNegativeX =
                                        totalTranslation model
                                in
                                Html.img
                                    [ Attributes.src (imageSrc i)
                                    , css
                                        [ width (pct 100)
                                        , property
                                            "transform"
                                            ("translateX(-" ++ String.fromFloat translateNegativeX ++ "px)")
                                        , property "transition" "transform 250ms"
                                        ]
                                    ]
                                    []
                            )
                    )
                , Html.div
                    [ css
                        [ displayFlex
                        , justifyContent spaceBetween
                        , width (px 200)
                        ]
                    ]
                    [ trackButton Prev
                    , playButton model.playerState
                    , trackButton Next
                    ]
                , viewDots model
                ]

            else
                [ Html.div
                    [ css
                        [ width (px 600)
                        , displayFlex
                        , cursor pointer
                        ]
                    , Events.onClick Start
                    , Attributes.property "aria-role" (Encode.string "button")
                    , Attributes.tabindex 0
                    ]
                    [ Html.img
                        [ Attributes.src "static/images/cover.jpg"
                        , Attributes.alt "Cover image for The Golem, by Sam Reider and the Human Hands"
                        , Events.onClick Start
                        , css [ width (pct 100) ]
                        ]
                        []
                    ]
                , imageButton
                    { action = Start
                    , src = "static/images/play.webp"
                    , alt = "Click to enter the golem"
                    , size = 32
                    }
                ]
    in
    Html.div
        [ css
            [ displayFlex
            , flexDirection column
            , justifyContent center
            , alignItems center
            , property "gap" "8px"
            ]
        ]
        internal


viewDots : Model -> Html msg
viewDots model =
    let
        numDots =
            16

        pxWidth =
            480

        ( dots, _ ) =
            Random.step (Random.list numDots dotGenerator) (Random.initialSeed 0)

        currentDot =
            Dict.get model.currentSong model.songMetadata
                |> Maybe.map .duration
                |> Maybe.withDefault 100000
                |> (\dur -> model.currentTime / dur)
                |> (\normalPos -> floor (normalPos * numDots))
    in
    Html.div
        [ css
            [ width (px pxWidth)
            , displayFlex
            , justifyContent center
            , property "gap" "8px"
            ]
        ]
        (dots
            |> List.indexedMap
                (\index dot_ ->
                    if index > currentDot then
                        dot_ palette.white

                    else
                        dot_ palette.blue
                )
        )


totalTranslation : Model -> Float
totalTranslation model =
    toFloat model.currentSong
        |> (*) 600


dot : { n : ( Int, Int ), s : ( Int, Int ), e : ( Int, Int ), w : ( Int, Int ) } -> Color -> Svg msg
dot { n, s, e, w } color =
    let
        toString ( x, y ) =
            String.fromInt x ++ " " ++ String.fromInt y

        pointPairs =
            [ s, e, w ] |> List.map toString

        d =
            [ "M "
            , toString n
            , " "
            , List.intersperse "L " pointPairs |> String.concat
            , " "
            , toString n
            , " Z"
            ]
                |> String.concat
    in
    Svg.svg
        [ SvgAttributes.width "12"
        , SvgAttributes.height "12"
        , SvgAttributes.viewBox "0 0 100 100"
        ]
        [ Svg.path
            [ SvgAttributes.css [ fill color ]
            , SvgAttributes.d d
            ]
            []
        ]


dotGenerator : Generator (Color -> Svg msg)
dotGenerator =
    let
        range =
            12

        fromBase ( x, y ) =
            Random.pair
                (Random.int (range * -1) range |> Random.map ((+) x) |> Random.map (clamp 0 100))
                (Random.int (range * -1) range |> Random.map ((+) y) |> Random.map (clamp 0 100))
    in
    Random.map
        (\n s e w ->
            dot { n = n, e = e, s = s, w = w }
        )
        (fromBase ( 50, 0 ))
        |> Random.andMap (fromBase ( 0, 50 ))
        |> Random.andMap (fromBase ( 50, 100 ))
        |> Random.andMap (fromBase ( 100, 50 ))



-- <?xml version="1.0" encoding="UTF-8"?>
-- <!-- Generated by Pixelmator Pro 3.3.11 -->
-- <svg width="100" height="100" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
--     <path fill="#000000" stroke="#000000" d="M 36 4 L 4 55 L 45 86 L 76 44 L 36 4 Z"/>
-- </svg>


type Direction
    = Next
    | Prev


trackButton : Direction -> Html Msg
trackButton direction =
    case direction of
        Next ->
            imageButton
                { action = PlayerAction NextAction
                , src = "static/images/next.webp"
                , alt = "Go to next song"
                , size = 16
                }

        Prev ->
            imageButton
                { action = PlayerAction PrevAction
                , src = "static/images/prev.webp"
                , alt = "Go to previous song"
                , size = 16
                }


playButton : PlayerState -> Html Msg
playButton state =
    case state of
        Playing ->
            imageButton
                { action = PlayerAction PauseAction
                , src = "static/images/pause.webp"
                , size = 32
                , alt = "pause button"
                }

        Paused ->
            imageButton
                { action = PlayerAction PlayAction
                , src = "static/images/play.webp"
                , size = 32
                , alt = "play button"
                }


imageButton : { action : Msg, src : String, size : Int, alt : String } -> Html Msg
imageButton { action, src, size, alt } =
    let
        paddingAmount =
            44 - size
    in
    Html.button
        [ Events.onClick action
        , css
            [ cursor pointer
            , property "width" "fit-content"
            , displayFlex
            , alignItems center
            , justifyContent center
            , backgroundColor transparent
            , border zero
            , padding (px <| toFloat paddingAmount)
            ]
        ]
        [ Html.img
            [ Attributes.src src
            , Attributes.width size
            , Attributes.height size
            , Attributes.alt alt
            ]
            []
        ]


palette =
    { white = rgb 203 172 139
    , blue = rgb 128 174 209
    }


imageSrc : Int -> String
imageSrc currentSong =
    "static/images/" ++ String.fromInt (currentSong + 1) ++ ".jpg"


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        metadataDecoder =
            Decode.map2 (\id duration -> ( id, duration ))
                (Decode.field "id" Decode.int)
                (Decode.field "duration" Decode.float)

        toReceivedMetadata value =
            case Decode.decodeValue metadataDecoder value of
                Ok ( songNumber, duration ) ->
                    ReceivedMetadata ( songNumber, { duration = duration } )

                Err e ->
                    NoOp

        timeUpdateDecoder =
            Decode.field "currentTime" Decode.float

        toReceivedTimeUpdate value =
            case Decode.decodeValue timeUpdateDecoder value of
                Ok currentTime ->
                    ReceivedTimeUpdate currentTime

                Err e ->
                    NoOp

        songendedDecoder =
            Decode.field "songNumber" Decode.int

        toReceivedSongEnded value =
            case Decode.decodeValue songendedDecoder value of
                Ok songNumber ->
                    ReceivedSongEnded songNumber

                Err e ->
                    NoOp
    in
    Sub.batch
        [ receivedMetadata toReceivedMetadata
        , receivedTimeUpdate toReceivedTimeUpdate
        , receivedSongEnded toReceivedSongEnded
        ]
