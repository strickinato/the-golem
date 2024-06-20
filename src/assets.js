const SQUARESPACE_SONGS = [
  {
    name: "In Darkness, a Rabbi's Prayer",
    imageUrl: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868496494-0D5MMIZ0ESF5XKKS0EOE/1.jpg",
    numeral: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868505000-SRRDFTDWPNW1F7IUQIO6/numeral-1.png",
    duration: 264.935997,
    startingTime: 0,
  },
  {
    name: "A Mysterious Stranger With An Extraordinary Idea",
    imageUrl: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868496560-P4BN5ZFBXDVQDHGXSQI9/2.jpg",
    numeral: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868505987-OJFVWFECY99UIK8VAW72/numeral-2.png",
    duration: 145.344,
    startingTime: 264.935997,
  },
  {
    name: "Gathering Clay, Making a Man",
    imageUrl: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868498618-CJALBRKH8Q10GJDR3TPQ/3.jpg",
    numeral: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868506450-7EOO5YXIKQTWJRY9JEXV/numeral-3.png",
    duration: 151.344,
    startingTime: 410.28,
  },
  {
    name: "Awakening Life With a Word",
    imageUrl: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868498455-ES0OJ0FO48S2JQSFAU1K/4.jpg",
    numeral: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868506921-SKQH72VTE4Q0KZTN1YDJ/numeral-4.png",
    duration: 105.408,
    startingTime: 561.624,
  },
  {
    name: "A Power Too Great To Control",
    imageUrl: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868500967-PL1VNS0U2DW8GJK6MLLC/5.jpg",
    numeral: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868507386-B7025DVVGY26HTTE6DQ1/numeral-5.png",
    duration: 156.12,
    startingTime: 667.032,
  },
  {
    name: "The Golem Falls In Love",
    imageUrl: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868500722-DUYVNF25RVMCSF959IZP/6.jpg",
    numeral: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868507816-V4CIRIN3HN0QL9J2E05K/numeral-6.png",
    duration: 255.048,
    startingTime: 823.152,
  },
  {
    name: "The Rabbi Chases and Destroys His Creation",
    imageUrl: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868502648-OQ2CLRF6QAU93MSE279G/7.jpg",
    numeral: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868508319-SCMJBT5ZKGDSFYLD3BIP/numeral-7.png",
    duration: 181.2,
    startingTime: 1078.2,
  },
  {
    name: "Return To Mud",
    imageUrl: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868503099-PJN0QBUE7479GK93SMRH/8.jpg",
    numeral: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868508886-FKNQSPEWBJ9DJI7UMGK5/numeral-8.png",
    duration: 109.056,
    startingTime: 1259.4
  },
]

const SQUARESPACE_MEDIA = {
  cover: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868505220-JONUPS2KIUJQLWB2C3CB/cover.jpg",
  next: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868504074-X0DTGSKUOXFS222Q75WK/next.png",
  pause: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868509268-YOAANRH2XRJPYR5DZBRX/pause.png",
  play: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868509769-A03J2LGDDQON0EK59L1F/play.png",
  prev: "https://images.squarespace-cdn.com/content/v1/5457d939e4b0d5b75c105e2f/1718868510279-N6U2EPB44JNYAH4OUJQC/prev.png",
}

const STATIC_SONGS = [
  {
    name: "In Darkness, a Rabbi's Prayer",
    imageUrl: "static/images/1.jpg",
    numeral: "static/images/numeral-1.png",
    duration: 264.935997,
    startingTime: 0,
  },
  {
    name: "A Mysterious Stranger With An Extraordinary Idea",
    imageUrl: "static/images/2.jpg",
    numeral: "static/images/numeral-2.png",
    duration: 145.344,
    startingTime: 264.935997,
  },
  {
    name: "Gathering Clay, Making a Man",
    imageUrl: "static/images/3.jpg",
    numeral: "static/images/numeral-3.png",
    duration: 151.344,
    startingTime: 410.28,
  },
  {
    name: "Awakening Life With a Word",
    imageUrl: "static/images/4.jpg",
    numeral: "static/images/numeral-4.png",
    duration: 105.408,
    startingTime: 561.624,
  },
  {
    name: "A Power Too Great To Control",
    imageUrl: "static/images/5.jpg",
    numeral: "static/images/numeral-5.png",
    duration: 156.12,
    startingTime: 667.032,
  },
  {
    name: "The Golem Falls In Love",
    imageUrl: "static/images/6.jpg",
    numeral: "static/images/numeral-6.png",
    duration: 255.048,
    startingTime: 823.152,
  },
  {
    name: "The Rabbi Chases and Destroys His Creation",
    imageUrl: "static/images/7.jpg",
    numeral: "static/images/numeral-7.png",
    duration: 181.2,
    startingTime: 1078.2,
  },
  {
    name: "Return To Mud",
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
