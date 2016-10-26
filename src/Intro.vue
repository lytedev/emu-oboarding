<template lang="pug">
#intro
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
</style>
