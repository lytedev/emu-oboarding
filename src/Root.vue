<template lang="pug">
#app-root
  #debug {{ debugData | name }}
  router-view
  slot
</template>

<script lang="coffee">
module.exports =
  computed:
    debugData: ->
      lspin: localStorage.pin
      lsverified: localStorage.verified
      entered: this.$store.getters.introEntered
      pin: this.$store.getters.introPin
      verified: this.$store.getters.introVerified
</script>

<style lang="stylus">
#debug
  position fixed
  bottom 0
  right 0
  padding 0.5rem 1rem
  background #023
  color #fff
  z-index 100000
</style>
