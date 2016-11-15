<template lang="pug">
.intro.stretchy-flex-column
  transition(name="topslide" appear)
    .cinematic-message-list
</template>

<script lang="coffee">
module.exports =
  components:
    'cinematic-message-list': require './components/CinematicMessageList.vue'
</script>

<style lang="stylus">
.intro
  height 6em

.text
  display flex
  justify-content center
  align-items center
</style>
