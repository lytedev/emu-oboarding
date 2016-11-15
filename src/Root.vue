<template lang="pug">
#root.stretchy-flex-column
  .debug(v-if="showDebug") {{ debugData }}
  router-view
  slot
</template>

<script lang="coffee">
module.exports =
  data: ->
    showDebug: false
  computed:
    debugData: ->
      lspin: localStorage.pin
      lsverified: localStorage.verified
      entered: this.$store.getters.introEntered
      pin: this.$store.getters.introPin
      verified: this.$store.getters.introVerified
</script>

<style lang="stylus">
.debug
  position fixed
  bottom 0
  right 0
  padding 0.5rem 1rem
  background #023
  color #fff
  z-index 100000

#root
  color #333

.stretchy-flex-column
  text-align center
  display flex
  flex-direction column
  justify-contents center
  align-items center
  text-align center
  height 6em

  & > *
    flex 1

.fade-enter-active, .fade-leave-active
  transition all 1s ease

.fade-enter, .fade-leave-active
  opacity 0
  flex .00001

.bottomslide
  transition all 1s ease
  position relative
  bottom 0
  flex 1

  &.bottomslide-enter, &.bottomslide-leave-active
    transition all 1s ease
    bottom -50%
    opacity 0
    flex .00001

.topslide
  transition all 1s ease
  position relative
  top 0
  flex 1

  &.topslide-enter, &.topslide-leave-active
    transition all 1s ease
    top -50%
    opacity 0
    flex .00001

</style>
