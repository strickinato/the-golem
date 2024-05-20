const node = document.getElementById("mount");
const flags = {}

const app = Elm.Main.init({
  node,
  flags,
});

let currentPlayer

for (let i = 0; i < 8; i++ ) {
  const el = document.getElementById(`song-${i+1}`)
  if (i === 0) {
    currentPlayer = el
  }
  el.addEventListener("loadedmetadata", () =>
    app.ports.metadataReceived.send({ id: i, duration: el.duration })
  )
  el.addEventListener("timeupdate", (e) => {
    app.ports.timeUpdateReceived.send({currentTime: e.target.currentTime})
  })
}

app.ports.clickedPlay.subscribe((songNumber) => {
  const player = document.getElementById(`song-${songNumber + 1}`);
  // They hit previous
  if (currentPlayer === player) {
    currentPlayer.currentTime = 0
  } else {
    currentPlayer?.pause()
    currentPlayer = player
  }
  requestAnimationFrame(() => player.play())
})
app.ports.clickedPause.subscribe(() => {
  currentPlayer.pause()
})
