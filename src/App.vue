<template lang="pug">
#app.intro
  intro-numpad
  console
</template>

<script lang="coffee">
require './styles/_variables.styl'

IntroNumpad = require './components/IntroNumpad.vue'
Console = require './components/Console.vue'

module.exports =
  name: 'app'
  components:
    IntroNumpad: IntroNumpad
    Console: Console
</script>

<style lang="stylus">
@import url('https://cdnjs.cloudflare.com/ajax/libs/normalize/5.0.0/normalize.min.css')
@import url('https://fonts.googleapis.com/css?family=Titillium+Web')
@import url('https://fonts.googleapis.com/icon?family=Material+Icons')
@import './styles/_variables.styl'
@import './styles/main.styl'

html, body, #app-mount
  min-height 100vh
  min-width 100vw
  display flex
  justify-content center
  align-items center

#app
  font-family 'Titillium Web', Helvetica, Arial, sans-serif
  -webkit-font-smoothing antialiased
  -moz-osx-font-smoothing grayscale
  text-align center
  color $page-foreground-color
  font-size 200%
  display flex
  justify-content center
  align-items center
  align-self center

  &.intro
    flex-direction column
    padding 1rem
    max-width 16rem
    margin 0 auto


</style>
