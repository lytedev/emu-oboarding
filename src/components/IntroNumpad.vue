<template lang="pug">
.intro-numpad
  input.pin-input(type="text" title="Enter the secure PIN using the numpad below" v-bind:value="pin" placeholder="Enter PIN" disabled)
  a.number-input.btn(v-html="v" v-for="v in values" v-on:click="addToPin(v)")
</template>

<script lang="coffee">
module.exports =
  name: 'hello'
  data: ->
    pin: ''

  computed:
    values: ->
      vals = '789456123'
      va = []
      for v in vals
        va.push v
      va.push '<i data-numpadaction="pinBackspace" title="Backspace" class="material-icons">undo</i>'
      va.push '0'
      va.push '<i data-numpadaction="pinSubmit" title="Submit" class="material-icons">publish</i>'
      return va

  methods:
    addToPin: (v) ->
      if v.length == 1
        this.pin += v
      else
        action = /data-numpadaction="(.*?)"/.exec(v)[1]
        this[action].apply this
    pinBackspace: ->
      this.pin = this.pin.substring(0, this.pin.length - 1)
    pinSubmit: ->
      this.$emit 'console-add-message', "Submitted #{this.pin.length * '*'}."
      this.pin = ''
      null
</script>

<style lang="stylus">
@import '../styles/_variables.styl'

.intro-numpad
  width 100%
  display flex
  justify-content space-between
  align-items space-between
  flex-wrap wrap

  .pin-input
    text-align center
    width 100%
    margin-bottom 1rem

  .number-input
    width 30%
    margin-bottom 1rem
    cursor pointer

  .console
    height 5rem
</style>
