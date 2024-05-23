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

const node = document.getElementById("mount");

const app = Elm.Main.init({
  node
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
            src: `static/images/${songNumber + 1}.jpg`,
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
