const SQUARESPACE_SONGS = [
  {
    name: "In Darkness, a Rabbi's Prayer",
    audioUrl: "https://static1.squarespace.com/static/5457d939e4b0d5b75c105e2f/t/6667dd89490aca5d53b5ab95/1718082960021/1.mp3/original/1.mp3",
    imageUrl: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/15cfd1e3-85f7-4788-8f5d-b0f521b4808f/1.jpg?format=2500w",
  },
  {
    name: "A Mysterious Stranger With An Extraordinary Idea",
    audioUrl: "https://static1.squarespace.com/static/5457d939e4b0d5b75c105e2f/t/6667f1859338655ff42489c0/1718088074006/2.mp3/original/2.mp3",
    imageUrl: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1957dae0-06c2-4751-9e29-1b8622cb936e/2.jpg?format=2500w"
  },
]

const SQUARESPACE_MEDIA = {
  cover: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718089684782-CP1H25GQEBIG78E5HG11/cover.jpg?format=2500",
  next: "/static/images/next.jpg",
  play: "/static/images/play.jpg",
  prev: "/static/images/prev.jpg",
  pause: "/static/images/pause.jpg",
}

const STATIC_SONGS = [
  {
    name: "In Darkness, a Rabbi's Prayer",
    audioUrl: "static/songs/1.mp3",
    imageUrl: "static/images/1.jpg",
    numeral: "static/images/numeral-1.png",
    duration: 264.935997,
    startingTime: 0,
  },
  {
    name: "A Mysterious Stranger With An Extraordinary Idea",
    audioUrl: "static/songs/2.mp3",
    imageUrl: "static/images/2.jpg",
    numeral: "static/images/numeral-2.png",
    duration: 145.344,
    startingTime: 264.935997,
  },
  {
    name: "Gathering Clay, Making a Man",
    audioUrl: "static/songs/3.mp3",
    imageUrl: "static/images/3.jpg",
    numeral: "static/images/numeral-3.png",
    duration: 151.344,
    startingTime: 410.28,
  },
  {
    name: "Awakening Life With a Word",
    audioUrl: "static/songs/4.mp3",
    imageUrl: "static/images/4.jpg",
    numeral: "static/images/numeral-4.png",
    duration: 105.408,
    startingTime: 561.624,
  },
  {
    name: "A Power Too Great To Control",
    audioUrl: "static/songs/5.mp3",
    imageUrl: "static/images/5.jpg",
    numeral: "static/images/numeral-5.png",
    duration: 156.12,
    startingTime: 667.032,
  },
  {
    name: "The Golem Falls In Love",
    audioUrl: "static/songs/6.mp3",
    imageUrl: "static/images/6.jpg",
    numeral: "static/images/numeral-6.png",
    duration: 255.048,
    startingTime: 823.152,
  },
  {
    name: "The Rabbi Chases and Destroys His Creation",
    audioUrl: "static/songs/7.mp3",
    imageUrl: "static/images/7.jpg",
    numeral: "static/images/numeral-7.png",
    duration: 181.2,
    startingTime: 1078.2,
  },
  {
    name: "Return To Mud",
    audioUrl: "static/songs/8.mp3",
    imageUrl: "static/images/8.jpg",
    numeral: "static/images/numeral-8.png",
    duration: 109.056,
    startingTime: 1259.4
  },
]


const STATIC_MEDIA = {
  cover: "/static/images/cover.jpg",
  next: "/static/images/next.png",
  play: "/static/images/play.png",
  prev: "/static/images/prev.png",
  pause: "/static/images/pause.png",
}

export const GET_ASSETS = () => {
  if (process.env.ASSET_TARGET === "squarespace") {
    return {
      SONGS: SQUARESPACE_SONGS,
      MEDIA_URLS: SQUARESPACE_MEDIA,
    }
  }

  return {
    SONGS: STATIC_SONGS,
    MEDIA_URLS: STATIC_MEDIA,
  }
}
