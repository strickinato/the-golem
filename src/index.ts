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
  requestAnimationFrame(() => player.play())
})
app.ports.clickedPause.subscribe(() => {
  window.CURRENT_GOLEM.pause()
})
