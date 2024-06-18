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
import List.Extra
import Random exposing (Generator)
import Random.Extra as Random exposing (andMap)
import Svg.Styled as Svg exposing (Svg)


port clickedPlay : () -> Cmd msg


port clickedPause : () -> Cmd msg


port goToTime : Float -> Cmd msg


main =
    Browser.element
        { init = init
        , update = update
        , view = view >> Html.toUnstyled
        , subscriptions = subscriptions
        }


type alias Model =
    { songs : Dict Int Song
    , playerState : PlayerState
    , currentTime : Float
    , mediaUrls : MediaUrls
    , hasStarted : Bool
    }


type alias Song =
    { name : String
    , audioUrl : String
    , imageUrl : String
    , duration : Float
    , numeralUrl : String
    , startingTime : Float
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
    | ReceivedTimeUpdate Float
    | ReceivedPlay
    | ReceivedPause
    | PlayerAction PlayerAction


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
    Decode.map6
        (\name audioUrl imageUrl numeralUrl duration startingTime ->
            { name = name
            , audioUrl = audioUrl
            , imageUrl = imageUrl
            , duration = duration
            , numeralUrl = numeralUrl
            , startingTime = startingTime
            }
        )
        (Decode.field "name" Decode.string)
        (Decode.field "audioUrl" Decode.string)
        (Decode.field "imageUrl" Decode.string)
        (Decode.field "numeral" Decode.string)
        (Decode.field "duration" Decode.float)
        (Decode.field "startingTime" Decode.float)


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
            , clickedPlay ()
            )

        ReceivedPlay ->
            ( { model | playerState = Playing }
            , Cmd.none
            )

        ReceivedPause ->
            ( { model | playerState = Paused }
            , Cmd.none
            )

        ReceivedTimeUpdate currentTime ->
            ( { model | currentTime = Debug.log "new cur time" currentTime }
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
            ( { model | playerState = Playing }, clickedPlay () )

        NextAction ->
            case nextSong model of
                Just song ->
                    ( { model | currentTime = song.startingTime }
                    , goToTime (Debug.log "GOING TO" song.startingTime)
                    )

                Nothing ->
                    ( model, Cmd.none )

        PrevAction ->
            case prevSong model of
                Just song ->
                    ( { model | currentTime = song.startingTime }
                    , goToTime (Debug.log "GOING TO" song.startingTime)
                    )

                Nothing ->
                    ( model, Cmd.none )


songsForTime : Model -> Float -> { current : Maybe ( Song, Int ), prev : Maybe Song, next : Maybe Song }
songsForTime model forTime =
    let
        curr =
            Dict.toList model.songs
                |> List.sortBy (\( _, { startingTime } ) -> startingTime)
                |> List.reverse
                |> List.Extra.find (\( i, song ) -> forTime >= song.startingTime)
    in
    case curr of
        Just ( i, song ) ->
            { current = Just ( song, i )
            , next = Dict.get (i + 1) model.songs
            , prev =
                if forTime - song.startingTime < 3 then
                    Dict.get (i - 1) model.songs

                else
                    Just song
            }

        Nothing ->
            { current = Nothing, prev = Nothing, next = Nothing }


currentSong : Model -> Maybe ( Song, Int )
currentSong model =
    songsForTime model model.currentTime
        |> .current


currentSongIndex : Model -> Maybe Int
currentSongIndex model =
    currentSong model
        |> Maybe.map Tuple.second


nextSong : Model -> Maybe Song
nextSong model =
    songsForTime model model.currentTime
        |> Debug.log "songs for time"
        |> .next


prevSong : Model -> Maybe Song
prevSong model =
    songsForTime model model.currentTime
        |> .prev



--     let
--         songsThatAlreadyStarted =
--             (model.songs |> Dict.values)
--                 |> List.filter (\song -> song.startingTime <= model.currentTime)
--     in
--     songsThatAlreadyStarted
--         |> List.Extra.last
-- nextSong : Model -> Maybe Song
-- nextSong model =
--     let
--         songsLeft =
--             (model.songs |> Dict.values) |> List.filter (\song -> song.startingTime <= model.currentTime)
--     in
--     case songsLeft of
--         [] ->
--             Nothing
--         [ onLastSong ] ->
--             Nothing
--         current :: next :: _ ->
--             Just next
-- prevSong : Model -> Maybe Song
-- prevSong model =
--     let
--         reversedSongsThatStarted =
--             (model.songs |> Dict.values)
--                 |> List.filter (\song -> song.startingTime <= model.currentTime)
--                 |> List.reverse
--     in
--     case reversedSongsThatStarted of
--         [] ->
--             Nothing
--          currentSong :: []  ->
--             Just currentSong
--         current :: next :: _ ->
--             Just next
-- let
--     defaultSong =
--         Dict.get 0 model.songs
-- in
-- case defaultSong of
--     Just song_ ->
--         List.foldr
--             (\song ( accDur, accSong ) ->
--                  case accSong of
--                      Just foundItAlreadySong ->
--                         (0, foundItAlreadySong)
--                      Nothing ->
--                         if model.currentTime < accDur then
--                             (accDur + song.duration, Nothing)
--             )
--             ( defaultSong.duration, Nothing )
--             (model.songs |> Dict.values)
--             |> Tuple.second
--     Nothing ->
--         Nothing


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
                        [ Attributes.src (Debug.log "HIHIH" model.mediaUrls.cover)
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
        (loadMainPlayer model :: internal)


loadMainPlayer : Model -> Html Msg
loadMainPlayer model =
    Html.audio
        [ Attributes.id "CURRENT-GOLEM-PLAYER"
        , Attributes.property "preload" (Encode.string "metadata")
        , Attributes.src <| "static/songs/full.mp3"
        , Events.on "timeupdate"
            (timeUpdateDecoder |> Decode.map ReceivedTimeUpdate)
        , Events.on "play" (Decode.succeed ReceivedPlay)
        , Events.on "pause" (Decode.succeed ReceivedPause)
        ]
        []


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
                            , if currentSongIndex model == Just i then
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
    currentSongIndex model
        |> Maybe.withDefault 0
        |> toFloat
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


timeUpdateDecoder : Decoder Float
timeUpdateDecoder =
    Decode.at [ "target", "currentTime" ] Decode.float


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch []
