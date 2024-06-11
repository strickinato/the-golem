import { Elm } from "./Main.elm";

const ELEMENT_ID = "golem-mount-point"

const ARTIST = "Sam Reider & The Human Hands"
const ALBUM = "The Golem and Other Tales"
const SONG_NAMES = [
  "In Darkness, a Rabbi's Prayer",
  "A Mysterious Stranger With An Extraordinary Idea",
  "Gathering Clay, Making a Man",
  "Awakening Life With a Word",
  "A Power Too Great To Control",
  "The Golem Falls In Love",
  "The Rabbi Chases and Destroys His Creation",
  "Return To Mud",
]

const SONGS = [
  {
    name: "In Darkness, a Rabbi's Prayer",
    audioUrl: "static/songs/1.mp3",
    imageUrl: "static/images/1.jpg",
  },
  {
    name: "A Mysterious Stranger With An Extraordinary Idea",
    audioUrl: "static/songs/2.mp3",
    imageUrl: "static/images/2.jpg",
  }
]

const node = document.getElementById(ELEMENT_ID);

const app = Elm.Main.init({
  node,
  flags: {
    songs: SONGS,
    coverUrl: "/static/images/cover.jpg"
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
        title: SONG_NAMES[songNumber],
        artist: ARTIST,
        album: ALBUM,
        artwork: [
          {
            src: SONGS[songNumber].audioUrl,
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
