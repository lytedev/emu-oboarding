<template lang="pug">
.console
  transition(appear v-on:enter="greet")
    textarea(disabled readonly) {{ text }}{{ pipe }}
</template>

<script lang="coffee">
module.exports =
  props: []
  data: ->
    stuff: 9
    text: ''
    queue: ''
    lastTimestamp: 0
    pipe: '|'
    pipeTime: 0
    maxPipeTime: 500
    timeouts: []
    intervals: []
  methods:
    test: ->
      null
    update: (timestamp) ->
      dt = timestamp - this.lastTimestamp
      this.lastTimestamp = timestamp

      if this.queue != ''
        this.text += this.queue.substring 0, 1
        this.queue = this.queue.substring 1
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
      msgTime = 2000
      dotPeriod = 400

      that = this
      this.timeouts.push setTimeout ->
        that.addMessage "Please submit your PIN."
      , msgTime
      this.timeouts.push setTimeout ->
        that.addMessage "Awaiting authorization"
      , msgTime * 1.2

      untilSubmission = ->
        that.intervals.push setInterval ->
          that.timeouts.push setTimeout ->
            that.addChars "."
          , dotPeriod * 1
          that.timeouts.push setTimeout ->
            that.addChars "."
          , dotPeriod * 2
          that.timeouts.push setTimeout ->
            that.addChars "."
          , dotPeriod * 3
          that.timeouts.push setTimeout ->
            that.deleteChars 1
          , dotPeriod * 4
          that.timeouts.push setTimeout ->
            that.deleteChars 1
          , dotPeriod * 5
          that.timeouts.push setTimeout ->
            that.deleteChars 1
          , dotPeriod * 6
        , dotPeriod * 6

      this.timeouts.push setTimeout untilSubmission, ((msgTime * 1.2) - (dotPeriod * 6))

      requestAnimationFrame this.update

    clearAllTimeoutsAndIntervals: ->
      for i of this.timeouts
        clearTimeout i
      for i of this.intervals
        clearInterval i

    addMessage: (msg) ->
      if this.text != ''
        this.queue += "\n"
      this.queue += msg
    addChars: (msg) ->
      this.queue += msg
    deleteChars: (n) ->
      this.text = this.text.substring 0, this.text.length - 1
      this.pipeTime = 0
      this.pipe = '|'
    clear: ->
      this.text = ""

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
    height 6rem
</style>
