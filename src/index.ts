import { Elm } from "./Main.elm";

const ELEMENT_ID = "golem-mount-point"

const ARTIST = "Sam Reider & The Human Hands"
const ALBUM = "The Golem and Other Tales"
const SONGS = [
  {
    name: "In Darkness, a Rabbi's Prayer",
    audioUrl: "static/songs/1.mp3",
    imageUrl: "static/images/1.jpg",
  },
  {
    name: "A Mysterious Stranger With An Extraordinary Idea",
    audioUrl: "static/songs/2.mp3",
    imageUrl: "static/images/2.jpg"
  },
  {
    name: "Gathering Clay, Making a Man",
    audioUrl: "static/songs/3.mp3",
    imageUrl: "static/images/3.jpg"
  },
  {
    name: "Awakening Life With a Word",
    audioUrl: "static/songs/4.mp3",
    imageUrl: "static/images/4.jpg"
  },
  {
    name: "A Power Too Great To Control",
    audioUrl: "static/songs/5.mp3",
    imageUrl: "static/images/5.jpg"
  },
  {
    name: "The Golem Falls In Love",
    audioUrl: "static/songs/6.mp3",
    imageUrl: "static/images/6.jpg"
  },
  {
    name: "The Rabbi Chases and Destroys His Creation",
    audioUrl: "static/songs/7.mp3",
    imageUrl: "static/images/7.jpg"
  },
  {
    name: "Return To Mud",
    audioUrl: "static/songs/8.mp3",
    imageUrl: "static/images/8.jpg"
  },
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
