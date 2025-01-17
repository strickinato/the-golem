port module Main exposing (..)

import Browser
import Browser.Dom
import Browser.Events
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
import Task


applicationID =
    "GOLEM_ELM_APPLICATION"


audioPlayerID =
    "GOLEM_ELM_PLAYER"


globalMaxWidth =
    maxWidth (px 600)


port clickedPlay : () -> Cmd msg


port clickedPause : () -> Cmd msg


port informSong : Int -> Cmd msg


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
    , enteredExperience : Entered
    , realAppWidth : Float
    }


type Entered
    = NotYet
    | FadingOut Float
    | FadingIn Float
    | InExperience


type alias Song =
    { name : String
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
    , fullSong : String
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
    | ReceivedTick Float
    | PlayerAction PlayerAction
    | GotWidth Float
    | Resized


type PlayerAction
    = PauseAction
    | PlayAction
    | NextAction
    | PrevAction
    | GoToSong Int


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
      , enteredExperience = NotYet
      , realAppWidth = flags.realWidth
      }
    , getWidth
    )


getWidth : Cmd Msg
getWidth =
    let
        handler res =
            case res of
                Ok scene ->
                    GotWidth scene.element.width

                Err _ ->
                    NoOp
    in
    Task.attempt handler (Browser.Dom.getElement applicationID)


type alias Flags =
    { songs : Dict Int Song
    , mediaUrls : MediaUrls
    , realWidth : Float
    }


flagsDecoder : Decoder Flags
flagsDecoder =
    Decode.map3 Flags
        (Decode.field "songs" songsDecoder)
        (Decode.field "mediaUrls" mediaUrlsDecoder)
        (Decode.field "width" Decode.float)


flagsDefault : Flags
flagsDefault =
    { songs = Dict.empty
    , mediaUrls = MediaUrls "" "" "" "" "" ""
    , realWidth = 0
    }


mediaUrlsDecoder : Decoder MediaUrls
mediaUrlsDecoder =
    Decode.map6 MediaUrls
        (Decode.field "cover" Decode.string)
        (Decode.field "pause" Decode.string)
        (Decode.field "play" Decode.string)
        (Decode.field "prev" Decode.string)
        (Decode.field "next" Decode.string)
        (Decode.field "fullSong" Decode.string)


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
    Decode.map5
        (\name imageUrl numeralUrl duration startingTime ->
            { name = name
            , imageUrl = imageUrl
            , duration = duration
            , numeralUrl = numeralUrl
            , startingTime = startingTime
            }
        )
        (Decode.field "name" Decode.string)
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
                , enteredExperience = FadingOut 0
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

        ReceivedTick tick ->
            ( advanceFade model tick, Cmd.none )

        ReceivedTimeUpdate currentTime ->
            let
                newModel =
                    { model | currentTime = currentTime }
            in
            ( newModel
            , case currentSongIndex newModel of
                Just i ->
                    informSong i

                Nothing ->
                    Cmd.none
            )

        PlayerAction playerAction ->
            updateGolemFromAction model playerAction

        GotWidth float ->
            ( { model | realAppWidth = float }, Cmd.none )

        Resized ->
            ( model, getWidth )


advanceFade : Model -> Float -> Model
advanceFade model float =
    let
        duration =
            500

        newExperience =
            case model.enteredExperience of
                NotYet ->
                    NotYet

                FadingOut cur ->
                    if cur + (float / duration) > 1 then
                        FadingIn 0

                    else
                        FadingOut <| cur + (float / duration)

                FadingIn cur ->
                    if cur + (float / duration) > 1 then
                        InExperience

                    else
                        FadingIn <| cur + (float / duration)

                InExperience ->
                    InExperience
    in
    { model | enteredExperience = newExperience }


updateGolemFromAction : Model -> PlayerAction -> ( Model, Cmd Msg )
updateGolemFromAction model playerAction =
    case playerAction of
        GoToSong int ->
            case timeForIndex model int of
                Just t ->
                    ( { model | currentTime = t }
                    , goToTime t
                    )

                Nothing ->
                    ( model, Cmd.none )

        PauseAction ->
            ( { model | playerState = Paused }, clickedPause () )

        PlayAction ->
            ( { model | playerState = Playing }
            , clickedPlay ()
            )

        NextAction ->
            case nextSong model of
                Just song ->
                    ( { model | currentTime = song.startingTime }
                    , goToTime song.startingTime
                    )

                Nothing ->
                    ( model, Cmd.none )

        PrevAction ->
            case prevSong model of
                Just song ->
                    ( { model | currentTime = song.startingTime }
                    , goToTime song.startingTime
                    )

                Nothing ->
                    ( model, Cmd.none )


timeForIndex : Model -> Int -> Maybe Float
timeForIndex model index =
    Dict.get index model.songs
        |> Maybe.map .startingTime


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
        |> .next


prevSong : Model -> Maybe Song
prevSong model =
    songsForTime model model.currentTime
        |> .prev


isFading : Model -> Bool
isFading model =
    case model.enteredExperience of
        NotYet ->
            False

        FadingOut _ ->
            True

        FadingIn _ ->
            True

        InExperience ->
            False


hasStarted : Model -> Bool
hasStarted model =
    case model.enteredExperience of
        NotYet ->
            False

        FadingOut _ ->
            False

        FadingIn _ ->
            True

        InExperience ->
            True


calcOpacity : Model -> Css.Style
calcOpacity model =
    case model.enteredExperience of
        NotYet ->
            batch []

        FadingOut f ->
            opacity (num (1 - f))

        FadingIn f ->
            opacity (num f)

        InExperience ->
            batch []


view : Model -> Html Msg
view model =
    let
        internal =
            if hasStarted model then
                [ Html.div
                    [ css
                        [ globalMaxWidth
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
                    [ trackButton model Prev
                    , playButton model
                    , trackButton model Next
                    ]
                ]

            else
                [ Html.div
                    [ css
                        [ globalMaxWidth
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
                    , src = model.mediaUrls.play
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
            , globalMaxWidth
            , margin2 zero auto
            , paddingTop (px 24)
            , calcOpacity model
            ]
        , Attributes.id applicationID
        ]
        (loadMainPlayer model :: internal)


loadMainPlayer : Model -> Html Msg
loadMainPlayer model =
    Html.audio
        [ Attributes.id audioPlayerID
        , Attributes.property "preload" (Encode.string "metadata")
        , Attributes.src <| model.mediaUrls.fullSong
        , Events.on "timeupdate"
            (timeUpdateDecoder |> Decode.map ReceivedTimeUpdate)
        , Events.on "play" (Decode.succeed ReceivedPlay)
        , Events.on "pause" (Decode.succeed ReceivedPause)
        ]
        []


viewDots : Model -> Html Msg
viewDots model =
    model.songs
        |> Dict.toList
        |> List.map
            (\( i, song ) ->
                Html.div
                    [ css
                        [ width (px 44)
                        , height (px 44)
                        , buttonStyles
                        ]
                    ]
                    [ Html.img
                        [ Attributes.src song.numeralUrl
                        , Attributes.alt ("Roman Numeral for" ++ String.fromInt (i + 1))
                        , Events.onClick (PlayerAction (GoToSong i))
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
        |> (*) model.realAppWidth


type Direction
    = Next
    | Prev


trackButton : Model -> Direction -> Html Msg
trackButton model direction =
    case direction of
        Next ->
            imageButton
                { action = PlayerAction NextAction
                , src = model.mediaUrls.next
                , alt = "Go to next song"
                , size = 16
                }

        Prev ->
            imageButton
                { action = PlayerAction PrevAction
                , src = model.mediaUrls.prev
                , alt = "Go to previous song"
                , size = 16
                }


playButton : Model -> Html Msg
playButton model =
    case model.playerState of
        Playing ->
            imageButton
                { action = PlayerAction PauseAction
                , src = model.mediaUrls.pause
                , size = 32
                , alt = "pause button"
                }

        Paused ->
            imageButton
                { action = PlayerAction PlayAction
                , src = model.mediaUrls.play
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
            [ buttonStyles
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


buttonStyles : Css.Style
buttonStyles =
    batch [ cursor pointer, hover [ opacity (num 0.8) ] ]


timeUpdateDecoder : Decoder Float
timeUpdateDecoder =
    Decode.at [ "target", "currentTime" ] Decode.float


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ if isFading model then
            Browser.Events.onAnimationFrameDelta ReceivedTick

          else
            Sub.batch []
        , Browser.Events.onResize (\_ _ -> Resized)
        ]
