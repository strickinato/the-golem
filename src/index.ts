const node = document.getElementById("mount");
const flags = {}

const app = Elm.Main.init({
  node,
  flags,
});


for (let i = 0; i < 8; i++) {
  const el = document.getElementById(`song-${i + 1}`)
  if (i === 0) {
    window.CURRENT_GOLEM = el
  }
  el.addEventListener("loadedmetadata", () =>
    app.ports.receivedMetadata.send({ id: i, duration: el.duration })
  )
  el.addEventListener("timeupdate", (e) => {
    app.ports.receivedTimeUpdate.send({ currentTime: e.target.currentTime })
  })
  el.addEventListener("ended", (e) => {
    app.ports.receivedSongEnded.send({ songNumber: i })
  })
}

app.ports.clickedPlay.subscribe((songNumber) => {
  const player = document.getElementById(`song-${songNumber + 1}`);
  // They hit previous
  if (window.CURRENT_GOLEM === player) {
    window.CURRENT_GOLEM.currentTime = 0
  } else {
    window.CURRENT_GOLEM?.pause()
    window.CURRENT_GOLEM = player
  }
  requestAnimationFrame(() => player.play())
})
app.ports.clickedPause.subscribe(() => {
  window.CURRENT_GOLEM.pause()
})
