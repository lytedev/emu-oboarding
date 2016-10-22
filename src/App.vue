<template lang="pug">
#app
  hello
</template>

<script lang="coffee">
require './styles/_variables.styl'

Hello = require './components/Hello.vue'

module.exports =
  name: 'app'
  components:
    Hello: Hello
</script>

<style lang="stylus">
@import url('https://cdnjs.cloudflare.com/ajax/libs/normalize/5.0.0/normalize.min.css')
@import url('https://fonts.googleapis.com/css?family=Titillium+Web')
@import './styles/_variables.styl'

#app
  font-family 'Titillium Web', Helvetica, Arial, sans-serif
  -webkit-font-smoothing antialiased
  -moz-osx-font-smoothing grayscale
  text-align center
  color $page-foreground-color
  font-size 200%
</style>
