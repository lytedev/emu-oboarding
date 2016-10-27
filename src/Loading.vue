<template lang="pug">
transition(appear v-on:enter="load" v-on:after-leave="unload")
  #loading()
    .status-container.big(v-bind:class="{ flyaway: !showText }"): h1() {{ text }}{{ ellipsis }}
    .status-container.sub(v-bind:class="{ flyaway: !contacted && updateEllipsis && leaving }"): p() {{ subtext }}
    transition(name="fade")
      canvas#streamer-canvas(v-if="!leaving")
    transition(name="fade")
      .enter-button.btn(v-if="status == 'online' && this.updateEllipsis == false" v-on:click="rockAndRoll") Entr
</template>

<script lang="coffee">
require './styles/_variables.styl'
mutationTypes = require '../store/mutation-types.coffee'

IntroNumpad = require './components/IntroNumpad.vue'
Console = require './components/Console.vue'

streamerColors = [
  "#ffaa00"
  "#444444"
  "#0af"
  "#777777"
  "#999999"
  "#881100"
]

streamers = []

module.exports =
  name: 'app'
  data: ->
    showText: true
    text: "Loding"
    subtext: "Initializng..."
    ellipsis: ""
    updateEllipsis: true
    fly: false
    lastTime: 0
    ellipsisTime: 0
    ellipsisPeriod: 333.333333
    streamerTime: 500
    streamerPeriod: 100
    maxStreamers: 50
    canvas: false
    context: false
    render: true
    updateStreamers: false
    serverStatusObtained: false
    minContactTime: 4000
    contacted: false
    leaving: false
  computed:
    status: ->
      status = this.$store.state.server.status
      status
  watch:
    status: (val, old) ->
      if val == "online" or val == "offline"
        this.serverStatusObtained = true
      val
  methods:
    rockAndRoll: (ev) ->
      sc1 = document.getElementById("slide-click-1")
      sc2 = document.getElementById("slide-click-2")
      errs = document.getElementById("error-sound")
      sucs = document.getElementById("success-sound")
      errs.volume = 0.5
      sucs.volume = 0.2
      sc1.muted = true
      sc2.muted = true
      errs.muted = true
      sucs.muted = true
      sc1.play()
      sc2.play()
      errs.play()
      sucs.play()
      setTimeout ->
        errs.muted = false
        sucs.muted = false
        sc1.muted = false
        sc2.muted = false
      , 3000

      document.getElementById("button-press").volume = 0.3
      document.getElementById("button-press").play()
      document.getElementById("click").play()
      document.getElementById("ambience").play()
      this.leaving = true
      this.contacted = false
      this.updateEllipsis = true
      that = this
      if that.status == "online"
        that.$store.commit mutationTypes.INTRO_ENTER
      setTimeout ->
        if that.status == "online"
          that.$router.push '/verification'
        else
          that.$router.push '/offline'
      , 1000
      if /Mobi/.test navigator.userAgent
        if (document.fullScreenElement && document.fullScreenElement != null) or (not document.mozFullScreen && not document.webkitIsFullScreen)
          if document.documentElement.requestFullScreen?
            document.documentElement.requestFullScreen()
          else if document.documentElement.mozRequestFullScreen?
            document.documentElement.mozRequestFullScreen()
          else if document.documentElement.webkitRequestFullScreen?
            document.documentElement.webkitRequestFullScreen()

    generateStreamer: ->
      cw = this.canvas.width
      ch = this.canvas.height
      streamer = {}
      streamer.color = streamerColors[Math.floor(Math.random()*streamerColors.length)]
      streamer.width = (ch / 600) + Math.random() * (ch / 30) / 2
      streamer.length = (cw / 10) + Math.random() * (cw * 2)
      streamer.speed = (cw / 1000) + Math.random() * (cw / 20)
      streamer.x = 0
      streamer.y = 0
      side = Math.random()
      if side > 0.5
        # start on right side, reverse speed
        streamer.x = cw - (streamer.width * 2)
        streamer.speed -= streamer.speed * 2
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
      if this.updateEllipsis
        this.ellipsisTime += dt
        if this.ellipsisTime > this.ellipsisPeriod
          if this.ellipsis == '...'
            this.ellipsis = ''
          else
            this.ellipsis += '.'
          this.ellipsisTime = this.ellipsisTime % this.ellipsisPeriod

      if not this.updateStreamers
        this.streamerTime = 0
      else
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
                break

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
          if (s.x + s.length < 1000 and s.speed < 0) or (s.x > cw + 1000 and s.speed > 0)
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

      if this.contacted and this.serverStatusObtained and this.updateEllipsis
        this.subtext = "Server Status: #{this.status.toUpperCase()}"
        that = this
        if that.status == 'online'
          # fade in enter button
          that.subtext += " (Corruption Detected)"
          setTimeout ->
            that.updateEllipsis = false
          , 1000
          that.ellipsis = ''
          that.showText = false
          sc1 = document.getElementById("slide-click-1")
          sc1.play()
        else
          this.text = "Offline"

      # request next render frame
      if this.render
        requestAnimationFrame this.update

    load: ->
      streamers = []
      if this.status == "online" or this.status == "offline"
        this.serverStatusObtained = true

      this.render = true
      this.canvas = document.getElementById "streamer-canvas"
      this.canvas.width = this.canvas.offsetWidth
      this.canvas.height = this.canvas.offsetHeight

      that = this
      window.addEventListener 'resize', ->
        that.canvas.width = that.canvas.offsetWidth
        that.canvas.height = that.canvas.offsetHeight

      this.context = this.canvas.getContext '2d'

      requestAnimationFrame this.update

      sc1 = document.getElementById 'slide-click-1'
      sc2 = document.getElementById 'slide-click-2'

      sc1.play()
      setTimeout ->
        sc2.play()
      , 600
      setTimeout ->
        sc1.currentTime = 0.5
      , 3000

      that = this
      setTimeout ->
        that.updateStreamers = true
        that.subtext = "Contacting server..."
      , 2000

      setTimeout ->
        that.contacted = true
      , this.minContactTime

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
    left -160vw
  50%
    left -160vw
  75%
    left 0
  100%
    left -3rem

@keyframes leftslideout
  0%
    left -3rem
  20%
    left 0
  70%
    left -160vw

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
    background-color #222
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
    border solid 0.2rem #333

    &.sub
      height 3rem
      bottom 6rem
      font-size 50%
      padding-bottom 0
      animation leftslidein 1.3s
      border-bottom-right-radius 0.5rem
      border-top-right-radius 0.5rem

    h1
      margin 0

    &.flyaway
      animation leftslideout 1s
      left -160vw

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
    transition top 0.8s cubic-bezier(0.26,-0.05,0.87,0), opacity 1s

    &.flyaway
      top 100vh

  .enter-button
    align-self center
    z-index 200
    text-align center
    position relative
    font-size 10vh
    max-width 4em
    cursor pointer

.fade-enter-active
.fade-leave-active
  transition opacity 0.5s

.fade-enter
.fade-leave-active
  opacity: 0

</style>
