<template lang="pug">
transition(appear v-on:enter="load" v-on:after-leave="unload")
  #loading()
    .status-container.big(v-bind:class="{ flyaway: fly }"): h1() {{ text }}{{ ellipsis }}
    .status-container.sub(v-bind:class="{ flyaway: fly }"): p() {{ subtext }}
    .updater {{ status }}
    canvas#streamer-canvas(v-bind:class="{ flyaway: fly }")
</template>

<script lang="coffee">
require './styles/_variables.styl'

IntroNumpad = require './components/IntroNumpad.vue'
Console = require './components/Console.vue'

streamerColors = [
  "#ffaa00"
  "#333333"
  "#0af"
  "#777777"
  "#999999"
  "#881100"
]

streamers = []

module.exports =
  name: 'app'
  data: ->
    text: "Loading"
    subtext: "Initializing..."
    ellipsis: ""
    fly: false
    lastTime: 0
    ellipsisTime: 0
    ellipsisPeriod: 333.333333
    streamerTime: 500
    streamerPeriod: 500
    maxStreamers: 10
    canvas: false
    context: false
    render: true
    updateStreamers: false
  computed:
    status: ->
      status = this.$store.state.server.status
      console.log status
      status
  methods:
    generateStreamer: ->
      cw = this.canvas.width
      ch = this.canvas.height
      streamer = {}
      streamer.color = streamerColors[Math.floor(Math.random()*streamerColors.length)]
      streamer.width = (cw / 100) + Math.random() * (cw / 5) / 2
      streamer.length = (cw / 10) + Math.random() * (cw * 2)
      streamer.speed = (cw / 10) + Math.random() * (cw * 2)
      streamer.x = 0
      streamer.y = 0
      if Math.random() > 0.5
        # start on right side, reverse speed
        streamer.x = cw - (streamer.width * 2)
        streamer.speed = 0 - (streamer.speed * 2)
      else
        streamer.x = 0 - streamer.length - (streamer.width * 2)
      streamer.y = - streamer.width + Math.random() * (ch + streamer.width)
      streamer

    update: (timestamp) ->
      # calculate delta time
      dt = timestamp - this.lastTime
      this.lastTime = timestamp
      dts = dt / 1000

      # update loading ellipsis
      this.ellipsisTime += dt
      if this.ellipsisTime > this.ellipsisPeriod
        if this.ellipsis == '...'
          this.ellipsis = ''
        else
          this.ellipsis += '.'
        this.ellipsisTime = this.ellipsisTime % this.ellipsisPeriod

      if this.updateStreamers
        # check if we need a new streamer and we have enough time
        cw = this.canvas.width
        ch = this.canvas.height
        this.streamerTime += dt
        if this.streamerTime > this.streamerPeriod
          if streamers.length < this.maxStreamers
            this.streamerTime = this.streamerTime % this.streamerPeriod
            streamers.push this.generateStreamer()
          else
            this.streamerTime = this.streamerTime % this.streamerPeriod
            for s of streamers
              if not streamers[s]?
                streamers[s] = this.generateStreamer()

        this.context.clearRect 0, 0, cw, ch

        # update and render the streamers
        removableStreamers = []
        # for i in [0..streamers.length]
        for i of streamers
          s = streamers[i]
          if not s?
            streamers[i] = undefined
            continue

          # if streamer is off screen, don't render and prepare it for removal
          if s.x + s.length < 0 or s.x > cw
            streamers[i] = undefined
            continue

          # move the streamers
          s.x = s.x + s.speed * dts

          # draw the streamers
          this.context.fillStyle = s.color
          this.context.strokeStyle = s.color
          this.context.lineWidth = s.width
          this.context.lineCap = "round"
          this.context.beginPath()
          this.context.moveTo s.x, s.y
          this.context.lineTo s.x + s.length, s.y
          this.context.stroke()

        # remove off-screen streamers
        for s of removableStreamers
          i = streamers.indexOf(s)
          if i != -1
            streamers.splice i, 1

      # request next render frame
      if this.render
        requestAnimationFrame this.update

    load: ->
      this.canvas = document.getElementById "streamer-canvas"
      this.canvas.width = this.canvas.offsetWidth
      this.canvas.height = this.canvas.offsetHeight

      window.addEventListener 'resize', ->
        this.canvas.width = this.canvas.offsetWidth
        this.canvas.height = this.canvas.offsetHeight

      this.context = this.canvas.getContext '2d'

      requestAnimationFrame this.update

      that = this
      setTimeout ->
        that.updateStreamers = true
        that.subtext = "Contacting server..."
      , 2000

    unload: ->
      this.render = false

    flyaway: ->
      this.fly = true

  components:
    IntroNumpad: IntroNumpad
    Console: Console

</script>

<style lang="stylus">
@import './styles/_variables.styl'

@keyframes fadein
  0%
    opacity 0
  /* 50%
    opacity 0.5 */
  100%
    opacity 1

@keyframes leftslidein
  0%
    left -100vw
  50%
    left -100vw
  75%
    left 0
  100%
    left -3rem

#loading
  background $page-background-color
  color $page-foreground-color
  animation fadein 0.5s
  position absolute
  left 0
  top 0
  bottom 0
  right 0
  height 100vh
  width 100vw
  display flex
  flex-direction column
  justify-content center
  align-items flex-start
  overflow-y hidden

  .status-container
    background-color #333
    border-bottom-right-radius 1rem
    border-top-right-radius 1rem
    margin-bottom -0.8rem
    z-index 100
    transition bottom 1s cubic-bezier(0.26,-0.05,0.87,0)
    position fixed
    bottom 10rem
    left -3rem
    width 22rem
    height 6rem
    padding-left 5rem
    padding-right 5rem
    padding-bottom 0.5rem
    text-shadow 0 0.1rem 0.1rem #111
    display flex
    justify-content flex-start
    align-items center
    opacity 1
    animation leftslidein 1s

    &.sub
      height 2rem
      bottom 7rem
      font-size 50%
      padding-bottom 0
      animation leftslidein 1.3s

    h1
      margin 0

    &.flyaway
      bottom 150vh

  .updater
    display none

  #streamer-canvas
    background-color
    width 100vw
    height 100vh
    position fixed
    top 0
    left 0
    bottom 0
    right 0
    transition top 0.8s cubic-bezier(0.26,-0.05,0.87,0)

    &.flyaway
      top 100vh

</style>
