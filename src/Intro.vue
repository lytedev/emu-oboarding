<template lang="pug">
transition(appear v-on:enter="load")
  #intro
    #intro-wrapper
      intro-numpad(v-if="showNumpad" v-on:verified="moveOn")
      console(v-if="showConsole" v-on:click="tempHideConsole" initialOutputFunction="verificationOutput" v-on:preverified="moveOn")
</template>

<script lang="coffee">
require './styles/_variables.styl'

IntroNumpad = require './components/IntroNumpad.vue'
Console = require './components/Console.vue'

module.exports =
  name: 'app'
  data: ->
    showNumpad: false
    showConsole: true
  computed: ->
    entered: ->
      this.$store.getters.introEntered
  components:
    IntroNumpad: IntroNumpad
    Console: Console
  methods:
    tempHideConsole: ->
      this.showConsole = false
      that = this
      setTimeout ->
        that.showConsole = true
      , 3000
    load: ->
      that = this
      if not this.$store.state.intro.entered
        that.$router.replace '/'
        return
      setTimeout ->
        that.showNumpad = true
        document.getElementById("slide-click-1").play()
      , 18000
    moveOn: ->
      this.showNumpad = false
      this.showConsole = false
      that = this
      setTimeout ->
        that.$router.push '/Terra'
      , 1000
</script>

<style lang="stylus">
#intro
  position fixed
  top 0
  bottom 0
  left 0
  right 0
  display flex
  flex-direction column
  justify-content center
  align-items center
  padding 1rem
  color #fff

  #intro-wrapper
    max-width 600px
</style>
