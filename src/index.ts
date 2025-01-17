import { Elm } from "./Main.elm";
import { GET_ASSETS } from "./assets"

const { SONGS, MEDIA_URLS } = GET_ASSETS()


const ELEMENT_ID = "golem-mount-point"
const GOLEM_PLAYER_ID = "GOLEM_ELM_PLAYER"

const ARTIST = "Sam Reider & The Human Hands"
const ALBUM = "The Golem and Other Tales"

const node = document.getElementById(ELEMENT_ID);
node.style.maxWidth = "600px";

const width = node?.getBoundingClientRect().width

const app = Elm.Main.init({
  node,
  flags: {
    width,
    songs: SONGS,
    mediaUrls: MEDIA_URLS,
  },
});


app.ports.informSong.subscribe((songNumber) => {
  if (window.navigator) {

    navigator.mediaSession.metadata = new MediaMetadata({
      title: SONGS[songNumber].name,
      artist: ARTIST,
      album: ALBUM,
      artwork: [
        {
          src: SONGS[songNumber].imageUrl,
          sizes: "878x878",
          type: "image/jpg",
        }
      ],
    });
  }
})

app.ports.clickedPause.subscribe(() => {
  const player = document.getElementById(GOLEM_PLAYER_ID);
  player.pause()
})

app.ports.clickedPlay.subscribe(() => {
  const player = document.getElementById(GOLEM_PLAYER_ID);
  player.play()
})

app.ports.goToTime.subscribe((time) => {
  const player = document.getElementById(GOLEM_PLAYER_ID);
  player.currentTime = time
})

