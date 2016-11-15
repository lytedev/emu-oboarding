<template lang="pug">
ul.cinematic-message-list
  li(v-for="message in messages") {{ message.text }}
</template>

<script lang="coffee">
mutationTypes = require '../../store/mutation-types.coffee'

clickAudio = document.getElementById "click"
clickAudio.volume = 0.2

module.exports =
  data: ->
    lastTime: 0
  methods:
    update: (timestamp) ->
      dt = timestamp - this.lastTime
      this.lastTime = timestamp

  mounted: ->

</script>

<style lang="stylus">
</style>
