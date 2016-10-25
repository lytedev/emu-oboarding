<template lang="pug">
.console
  transition(appear v-on:enter="greet")
    textarea#console-textarea(disabled readonly) {{ text }}{{ pipe }}
  //- p {{ queue }}
</template>

<script lang="coffee">
mutationTypes = require '../../store/mutation-types.coffee'

console.log mutationTypes

module.exports =
  props: []
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
        this.$store.commit mutationTypes.CONSOLE_UPDATE_CHARS, { chars: 1 }
        this.pipe = '|'
        this.pipeTime = 0
      else
        this.pipeTime += dt
        if this.pipeTime > this.maxPipeTime
          if this.pipe == ''
            this.pipe = '|'
          else
            this.pipe = ''
          this.pipeTime = this.pipeTime % this.maxPipeTime

      requestAnimationFrame this.update
    greet: ->
      this.textareaElement = document.getElementById "console-textarea"
      msgTime = 0

      that = this
      this.timeouts.push setTimeout ->
        that.addMessage "Please submit your PIN or swipe access card."
      , msgTime

      requestAnimationFrame this.update

    clearAllTimeoutsAndIntervals: ->
      for i of this.timeouts
        clearTimeout i
      for i of this.intervals
        clearInterval i

    addMessage: (msg) ->
      this.$store.commit mutationTypes.CONSOLE_ADD_LINE_TO_QUEUE, { text: msg }
    addChars: (msg) ->
      this.$store.commit mutationTypes.CONSOLE_ADD_LINE_TO_QUEUE, { text: msg }
    deleteChars: (n) ->
      this.$store.commit mutationTypes.CONSOLE_DELETE_CHARS, { chars: 1 }
      this.pipeTime = 0
      this.pipe = '|'
    clear: ->
      this.$store.commit mutationTypes.CONSOLE_CLEAR_TEXT

  activate: (done) ->
    console.log "Console Activate"
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

  textarea
    resize none
    width 100%
    height 6.66rem
    overflow-y hidden
</style>
