port module Main exposing (..)

import Browser
import Css exposing (..)
import Dict exposing (Dict)
import Html.Styled as Html exposing (Attribute, Html)
import Html.Styled.Attributes as Attributes exposing (css)
import Html.Styled.Events as Events
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as Decode
import Json.Encode as Encode
import Random exposing (Generator)
import Random.Extra as Random exposing (andMap)
import Svg.Styled as Svg exposing (Svg)
import Svg.Styled.Attributes as SvgAttributes


port clickedPlay : Int -> Cmd msg


port clickedPause : () -> Cmd msg


main =
    Browser.element
        { init = init
        , update = update
        , view = view >> Html.toUnstyled
        , subscriptions = subscriptions
        }


type alias Model =
    { songs : Dict Int Song
    , currentSong : Int
    , playerState : PlayerState
    , currentTime : Float
    , mediaUrls : MediaUrls
    , hasStarted : Bool
    }


type alias Song =
    { name : String
    , audioUrl : String
    , imageUrl : String
    , duration : Maybe Float
    , numeralUrl : String
    }


type alias MediaUrls =
    { cover : String
    , pause : String
    , play : String
    , prev : String
    , next : String
    }


type PlayerState
    = Playing
    | Paused


type Msg
    = NoOp
    | Start
    | ReceivedMetadata Int Metadata
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


init : Encode.Value -> ( Model, Cmd Msg )
init incomingJson =
    let
        flags =
            Decode.decodeValue flagsDecoder incomingJson
                |> Result.withDefault flagsDefault
    in
    ( { songs = flags.songs
      , currentSong = 0
      , mediaUrls = flags.mediaUrls
      , playerState = Paused
      , currentTime = 0
      , hasStarted = False
      }
    , Cmd.none
    )


type alias Flags =
    { songs : Dict Int Song, mediaUrls : MediaUrls }


flagsDecoder : Decoder Flags
flagsDecoder =
    Decode.map2 Flags
        (Decode.field "songs" songsDecoder)
        (Decode.field "mediaUrls" mediaUrlsDecoder)


flagsDefault : Flags
flagsDefault =
    { songs = Dict.empty
    , mediaUrls = MediaUrls "" "" "" "" ""
    }


mediaUrlsDecoder : Decoder MediaUrls
mediaUrlsDecoder =
    Decode.map5 MediaUrls
        (Decode.field "cover" Decode.string)
        (Decode.field "pause" Decode.string)
        (Decode.field "play" Decode.string)
        (Decode.field "prev" Decode.string)
        (Decode.field "next" Decode.string)


songsDecoder : Decoder (Dict Int Song)
songsDecoder =
    Decode.indexedList
        (\i ->
            songDecoder
                |> Decode.map (\s -> ( i, s ))
        )
        |> Decode.map Dict.fromList


songDecoder : Decoder Song
songDecoder =
    Decode.map4
        (\name audioUrl imageUrl numeralUrl ->
            { name = name
            , audioUrl = audioUrl
            , imageUrl = imageUrl
            , duration = Nothing
            , numeralUrl = numeralUrl
            }
        )
        (Decode.field "name" Decode.string)
        (Decode.field "audioUrl" Decode.string)
        (Decode.field "imageUrl" Decode.string)
        (Decode.field "numeral" Decode.string)


totalSongs : Model -> Int
totalSongs model =
    model.songs |> Dict.size


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

        ReceivedMetadata songNumber metaData ->
            let
                updateFn song =
                    song |> Maybe.map (\s -> { s | duration = Just metaData.duration })
            in
            ( { model | songs = Dict.update songNumber updateFn model.songs }
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
                    min (totalSongs model - 1) (model.currentSong + 1)
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
                        [ maxWidth (px 800)
                        , displayFlex
                        , overflow hidden
                        ]
                    ]
                    (model.songs
                        |> Dict.toList
                        |> List.map
                            (\( i, song ) ->
                                let
                                    translateNegativeX =
                                        totalTranslation model
                                in
                                Html.img
                                    [ Attributes.src song.imageUrl
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
                , viewDots model
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
                ]

            else
                [ Html.div
                    [ css
                        [ maxWidth (px 800)
                        , displayFlex
                        , cursor pointer
                        ]
                    , Events.onClick Start
                    , Attributes.property "aria-role" (Encode.string "button")
                    , Attributes.tabindex 0
                    ]
                    [ Html.img
                        [ Attributes.src model.mediaUrls.cover
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
            , property "gap" "24px"
            , maxWidth (px 800)
            , margin2 zero auto
            , paddingTop (px 24)
            ]
        ]
        (loadPlayers model :: internal)


loadPlayers : Model -> Html Msg
loadPlayers model =
    let
        player ( int, song ) =
            Html.audio
                [ Attributes.id <| "song-" ++ String.fromInt (int + 1)
                , Attributes.property "preload" (Encode.string "metadata")
                , Attributes.src <| song.audioUrl
                , Events.on "loadedmetadata"
                    (metadataDecoder |> Decode.map (ReceivedMetadata int))
                , Events.on "timeupdate"
                    (timeUpdateDecoder |> Decode.map ReceivedTimeUpdate)
                , Events.on "ended"
                    (Decode.succeed (ReceivedSongEnded int))
                ]
                []
    in
    Html.div [ css [ display none ] ]
        (model.songs |> Dict.toList |> List.map player)


viewDots : Model -> Html msg
viewDots model =
    model.songs
        |> Dict.toList
        |> List.map
            (\( i, song ) ->
                Html.div
                    [ css [ width (px 44), height (px 44) ] ]
                    [ Html.img
                        [ Attributes.src song.numeralUrl
                        , Attributes.alt ("Roman Numeral for" ++ String.fromInt (i + 1))
                        , css
                            [ width (pct 100)
                            , if model.currentSong == i then
                                property "filter" "hue-rotate(180deg)"

                              else
                                batch []
                            ]
                        ]
                        []
                    ]
            )
        |> Html.div
            [ css
                [ displayFlex
                , property "gap" "24px"
                , alignItems center
                , justifyContent center
                , width (pct 100)
                , padding2 zero (px 24)
                ]
            ]


totalTranslation : Model -> Float
totalTranslation model =
    toFloat model.currentSong
        |> (*) 800


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


metadataDecoder : Decoder Metadata
metadataDecoder =
    Decode.map Metadata
        (Decode.at [ "target", "duration" ] Decode.float)


timeUpdateDecoder : Decoder Float
timeUpdateDecoder =
    Decode.at [ "target", "currentTime" ] Decode.float


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch []
