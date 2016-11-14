<template lang="pug">
transition(appear v-on:enter="greet" name="slideupin")
  .console(v-on:click="$emit('hideme')" v-bind:class="classes")
    textarea#console-textarea(disabled readonly) {{ text }}{{ pipe }}
  //- p {{ queue }}
</template>

<script lang="coffee">
mutationTypes = require '../../store/mutation-types.coffee'

clickAudio = document.getElementById "click"
clickAudio.volume = 0.2

consoleCommands =
  speed: (newSpeed) ->
    console.log "Console Speed Update! #{this.speed} -> #{newSpeed}"
    this.speed = newSpeed

module.exports =
  props:
    initialOutputFunction: String
    outputData: Object
    classes: String
  computed:
    text: ->
      this.textareaElement.scrollTop = this.textareaElement.scrollHeight
      this.$store.getters.consoleText
    verified: ->
      this.$store.getters.introVerified
    pin: ->
      this.$store.getters.introPin
    queue: ->
      this.$store.getters.consoleQueue
  data: ->
    textareaElement: false
    lastTimestamp: 0
    pipe: '|'
    pipeTime: 0
    charTime: 0
    maxPipeTime: 500
    timeouts: []
    intervals: []
    speed: 20
  methods:
    update: (timestamp) ->
      dt = timestamp - this.lastTimestamp
      this.lastTimestamp = timestamp

      if this.queue != ''
        if clickAudio?
          clickAudio.muted = false

        this.pipe = '|'
        this.pipeTime = -1000

        this.charTime += dt

        # if enough time has passed that we can render a character
        if this.charTime > this.speed
          if this.speed == 0
            # if we're rendering from the queue instantly, we just load the whole queue
            numChars = this.queue.length
            this.charTime = 0
          else
            # figure out how many characters we render
            numChars = Math.floor(this.charTime / this.speed)
            # cut that much time out of our timer
            this.charTime -= numChars * this.speed

          # look for a command character in the substring we're about to push
          commandCharIndex = this.queue.substring(0, numChars).indexOf('`')
          if commandCharIndex > -1
            # if we find one, cut the number of characters down to the character
            # before the command character
            numChars = commandCharIndex

            # extract the command and arguments
            re = /`([a-zA-Z0-9-_]*?)\((.*)\)/
            matches = this.queue.match re
            if matches?
              console.log "MATCHES", commandCharIndex, numChars, matches, this.queue
              if matches.length > 2
                this.$store.commit mutationTypes.CONSOLE_DELETE_QUEUE_CHARS, { chars: matches[0].length }
                consoleCommands[matches[1]].apply this, JSON.parse("[#{matches[2]}]")
          this.$store.commit mutationTypes.CONSOLE_UPDATE_CHARS, { chars: numChars }

      else
        if clickAudio?
          clickAudio.muted = true
        this.pipeTime += dt
        if this.pipeTime > this.maxPipeTime
          if this.pipe == ''
            this.pipe = '|'
          else
            this.pipe = ''
          this.pipeTime = this.pipeTime % this.maxPipeTime

      requestAnimationFrame this.update
    greet: ->
      this.clear()
      this.textareaElement = document.getElementById "console-textarea"

      if this.initialOutputFunction?
        this[this.initialOutputFunction]()

      requestAnimationFrame this.update
      this.websocketCheck()

    verificationOutput: ->
      that = this
      offset = 0
      setTimeout ->
        that.addMessage "Running initial systems diagnostics"
      , offset += 1500
      setTimeout ->
        that.addChars "."
      , offset += 1000
      setTimeout ->
        that.addChars "."
      , offset += 400
      setTimeout ->
        that.addChars "."
      , offset += 400

      setTimeout ->
        offset = 0
        if that.verified
          that.addMessage "Returning user detected. Redirecting..."
          setTimeout ->
            that.$emit 'preverified'
          , offset += 1500

        else
          that.addMessage "Verifying identity and creating secure connection"
          setTimeout ->
            that.addChars "."
          , offset += 1000
          setTimeout ->
            that.addChars "."
          , offset += 400
          setTimeout ->
            that.addChars "."
          , offset += 400

          setTimeout ->
            that.addMessage "No compatibe identification peripheral detected. Are you sure it is plugged in?"
          , offset += 1500
          setTimeout ->
            that.addMessage "Plug it in and try again or dial your operator."
          , offset += 5000
      , offset += 1500

    websocketCheck: ->
      null

    clearAllTimeoutsAndIntervals: ->
      for i of this.timeouts
        clearTimeout i
      for i of this.intervals
        clearInterval i

    addMessage: (msg) ->
      this.$store.commit mutationTypes.CONSOLE_ADD_LINE_TO_QUEUE, { text: msg }
      this.pipeTime = 0
      this.pipe = '|'
    addChars: (msg) ->
      this.$store.commit mutationTypes.CONSOLE_ADD_TO_QUEUE, { text: msg }
      this.pipeTime = 0
      this.pipe = '|'
    deleteChars: (n) ->
      this.$store.commit mutationTypes.CONSOLE_DELETE_CHARS, { chars: 1 }
      this.pipeTime = 0
      this.pipe = '|'
    clear: ->
      this.$store.commit mutationTypes.CONSOLE_CLEAR_TEXT
      this.$store.commit mutationTypes.CONSOLE_CLEAR_QUEUE
    clearText: ->
      this.$store.commit mutationTypes.CONSOLE_CLEAR_TEXT

  activate: (done) ->
    that = this
    requestAnimationFrame this.update
    done()
  events:
    'console-add-message': (msg) ->
      this.addMessage msg
    'console-clear': ->
      this.text = ''
</script>

<style lang="stylus">
@import '../styles/_variables.styl'

.console
  width 100%
  flex-grow 1
  min-width 20rem
  position relative

  &.big
    position fixed
    top 0
    bottom 0
    left 0
    right 0
    font-family monospace

    textarea
      position fixed
      top 0
      bottom 0
      left 0
      right 0
      border 0
      border-radius 0
      max-width 100%
      max-height 100%
      height 100%
      width 100%

  textarea
    resize none
    width 100%
    height 8.5rem
    line-height 1.5rem
    overflow-y hidden
    overflow-wrap break-word
    word-wrap break-word
    word-break break-all
    word-break break-word
    hyphens auto
    color #fff

@keyframes slideupout
  0%
    max-height 10rem
    top 0
    opacity 1
  20%
    top -3rem
  60%
    top 200vh
  100%
    max-height 0rem
    opacity 0
    top 200vh

@keyframes slideupin
  0%
    max-height 0
    opacity 0
    top 200vh
  20%
    top 200vh
  60%
    top -3rem
  100%
    max-height 10rem
    top 0
    opacity 1

.slideupin-enter-active
  top 0
  animation slideupin 0.6s

.slideupin-leave-active
  background-color #f00
  top 0
  animation slideupout 0.6s

.slideupin-enter
.slideupin-leave-active
  position relative
  top 200vh

</style>
