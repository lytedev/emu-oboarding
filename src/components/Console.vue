<template lang="pug">
transition(appear v-on:enter="greet" name="slideupin")
  .console(v-on:click="$emit('hideme')")
    textarea#console-textarea(disabled readonly) {{ text }}{{ pipe }}
  //- p {{ queue }}
</template>

<script lang="coffee">
mutationTypes = require '../../store/mutation-types.coffee'

clickAudio = document.getElementById "click"
clickAudio.volume = 0.2

module.exports =
  props: ['initialOutputFunction']
  computed:
    text: ->
      this.textareaElement.scrollTop = this.textareaElement.scrollHeight
      this.$store.state.console.text
    queue: ->
      this.$store.state.console.queue
  data: ->
    textareaElement: false
    lastTimestamp: 0
    pipe: '|'
    pipeTime: 0
    maxPipeTime: 500
    timeouts: []
    intervals: []
  methods:
    update: (timestamp) ->
      dt = timestamp - this.lastTimestamp
      this.lastTimestamp = timestamp

      if this.queue != ''
        if clickAudio?
          clickAudio.muted = false
        this.$store.commit mutationTypes.CONSOLE_UPDATE_CHARS, { chars: 1 }
        this.pipe = '|'
        this.pipeTime = 0
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
        that.addMessage "Verifying identity and creating secure connection"
      , offset += 1500
      setTimeout ->
        that.addChars "."
      , offset += 1500
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


    websocketCheck: ->
      null

    clearAllTimeoutsAndIntervals: ->
      for i of this.timeouts
        clearTimeout i
      for i of this.intervals
        clearInterval i

    addMessage: (msg) ->
      this.$store.commit mutationTypes.CONSOLE_ADD_LINE_TO_QUEUE, { text: msg }
    addChars: (msg) ->
      this.$store.commit mutationTypes.CONSOLE_ADD_TO_QUEUE, { text: msg }
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
