const node = document.getElementById("mount");
const flags = {}

const app = Elm.Main.init({
  node,
  flags,
});

app.ports.clickedPlay.subscribe(() => {
  const player = document.querySelector('audio');
  player.play()
})
app.ports.clickedPause.subscribe(() => {
  const player = document.querySelector('audio');
  player.pause()
})
