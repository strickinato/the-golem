import { Elm } from "./Main.elm";
import { SONGS } from "./songs"

const MEDIA_URLS = {
  cover: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718089684782-CP1H25GQEBIG78E5HG11/cover.jpg?format=2500",
  next: "/static/images/next.jpg",
  play: "/static/images/play.jpg",
  prev: "/static/images/prev.jpg",
  pause: "/static/images/pause.jpg",
}

const ELEMENT_ID = "golem-mount-point"

const ARTIST = "Sam Reider & The Human Hands"
const ALBUM = "The Golem and Other Tales"

const node = document.getElementById(ELEMENT_ID);

const app = Elm.Main.init({
  node,
  flags: {
    songs: SONGS,
    mediaUrls: MEDIA_URLS,
  },
});


app.ports.clickedPlay.subscribe((songNumber) => {
  const player = document.getElementById(`song-${songNumber + 1}`);
  // They hit previous
  if (window.CURRENT_GOLEM === player) {
    window.CURRENT_GOLEM.currentTime = 0
  } else {
    window.CURRENT_GOLEM?.pause()
    window.CURRENT_GOLEM = player
  }
  requestAnimationFrame(() => {
    player.play()

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
})
app.ports.clickedPause.subscribe(() => {
  window.CURRENT_GOLEM.pause()
})
