<template lang="pug">
.console
  textarea(disabled readonly)
</template>

<script lang="coffee">
module.exports =
  props: []
  data: ->
    stuff: 9
    text: ''
  methods:
    test: ->
      null
  events:
    'console-add-message': (msg) ->
      this.text += msg
    'console-clear': ->
      this.text = ''
</script>

<style lang="stylus">
@import '../styles/_variables.styl'
</style>
