<template lang="pug">
transition(appear v-on:enter="load" name="slidedownin")
  .intro-numpad
    input.pin-input(type="text" title="Enter the secure PIN using the numpad below" v-bind:value="pin" placeholder="Enter PIN" disabled)
    a.number-input.btn(v-html="v" v-for="v in values" v-on:click="addToPin(v)")
</template>

<script lang="coffee">
mutationTypes = require '../../store/mutation-types.coffee'

module.exports =
  name: 'hello'
  data: ->
    pin: ''
    submitting: false
    apiCallInProgress: false
    movingOn: false

  computed:
    values: ->
      vals = '789456123'
      va = []
      for v in vals
        va.push v
      va.push '<i data-numpadaction="pinBackspace" title="Backspace" class="material-icons">&#xE166;</i>'
      va.push '0'
      va.push '<i data-numpadaction="pinSubmit" title="Submit" class="material-icons">&#xE255;</i>'
      return va

  methods:
    load: ->
      that = this

      # hook into the websocket messages
      onMessage = (ev) ->
        if ev.data?
          data = JSON.parse ev.data
          if data.verification?
            that.apiCallInProgress = false
            that.$ws.removeEventListener 'message', onMessage
            if data.verification == "accepted"
               that.$store.commit mutationTypes.INTRO_SET_VERIFIED, { verified: true }
              that.movingOn = true
            that.pinSubmitCallback()

      this.$ws.addEventListener 'message', onMessage
    pinSubmitCallback: ->
      if not this.submitting and not this.apiCallInProgress

        this.submitting = false
        this.apiCallInProgress = false
        that = this

        if this.movingOn
          document.getElementById("success-sound").play()
          this.$store.commit mutationTypes.CONSOLE_ADD_LINE_TO_QUEUE, { text: "Accepted. Redirecting..." }
          offset = 2000
          setTimeout ->
            that.$emit 'verified'
          , offset += 400

        else
          document.getElementById("error-sound").play()
          this.$store.commit mutationTypes.CONSOLE_ADD_LINE_TO_QUEUE, { text: "Invalid PIN. Try again." }

    addToPin: (v) ->
      bp = document.getElementById("button-press")
      bp.pause()
      bp.currentTime = 0
      bp.play()
      if v.length == 1
        this.pin += v
      else
        action = /data-numpadaction="(.*?)"/.exec(v)[1]
        this[action].apply this

    pinBackspace: ->
      this.pin = this.pin.substring(0, this.pin.length - 1)

    pinSubmit: ->
      if this.submitting then return
      if this.pin == '' then return

      this.submitting = true
      that = this

      # send pin to API
      that.movingOn = false
      this.apiCallInProgress = true
      this.$ws.send "dial: #{this.pin}"
      this.$store.commit mutationTypes.INTRO_SET_PIN, { pin: this.pin }

      this.$store.commit mutationTypes.CONSOLE_ADD_LINE_TO_QUEUE, { text: "Submitted #{new Array(this.pin.length + 1).join('*')} - Awaiting response" }
      this.pin = ''
      offset = 400

      that = this
      setTimeout ->
        that.$store.commit mutationTypes.CONSOLE_ADD_TO_QUEUE, { text: "." }
      , offset += 400
      setTimeout ->
        that.$store.commit mutationTypes.CONSOLE_ADD_TO_QUEUE, { text: "." }
      , offset += 400
      setTimeout ->
        that.$store.commit mutationTypes.CONSOLE_ADD_TO_QUEUE, { text: "." }
      , offset += 400
      setTimeout ->
        that.submitting = false
        that.pinSubmitCallback()
      , offset += 1000


</script>

<style lang="stylus">
@import '../styles/_variables.styl'

.intro-numpad
  width 100%
  display flex
  justify-content space-between
  align-items space-between
  flex-wrap wrap
  text-align center

  .pin-input
    text-align center
    width 100%
    margin-bottom 1rem

  .number-input
    width 30%
    margin-bottom 1rem
    cursor pointer

@keyframes slidedownout
  0%
    top 0
    max-height 0
    max-width 20rem
    opacity 1
    max-height 30rem
    max-width 600px
  100%
    opacity 0
    max-height 0
    max-width 20rem
    top -100vh

@keyframes slidedownin
  0%
    opacity 0
    max-height 0
    max-width 20rem
    top -100vh
  100%
    top 0
    max-height 0
    max-width 20rem
    opacity 1
    max-height 30rem
    max-width 600px

.slidedownin-enter-active
  top 0
  animation slidedownin 1s
  position relative
  max-height 50rem

.slidedownin-leave-active
  top 0
  animation slidedownout 1s
  position relative
  max-height 50rem

.slidedownin-enter
.slidedownin-leave-active
  position relative
  top -100vh
  max-height 0

</style>
