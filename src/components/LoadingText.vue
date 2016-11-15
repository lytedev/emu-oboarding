<template lang="pug">
.loading-text {{ text }}
    span.visible-dots {{ visibleDots }}
    span.invisible-dots {{ invisibleDots }}
</template>

<script lang="coffee">
module.exports =
  props:
    text:
      type: String
      default: "Loading"
    isLoading:
      type: Boolean
      default: true
  data: ->
    visibleDots: ''
    invisibleDots: '...'

    ellipseTimer: 0
    ellipseCycle: 400
    lastTime: 0
  methods:
    update: (timestamp) ->
      requestAnimationFrame this.update

      dt = timestamp - this.lastTime
      this.lastTime = timestamp

      if this.isLoading
        this.ellipseTimer += dt
        if this.ellipseTimer > this.ellipseCycle
          this.ellipseTimer %= this.ellipseCycle
          if this.visibleDots.length > 2
            this.visibleDots = ''
            this.invisibleDots = '...'
          else
            this.visibleDots += '.'
            this.invisibleDots = ''
            while this.invisibleDots.length + this.visibleDots.length < 3
              this.invisibleDots += '.'
      else
        this.visibleDots = ""
        this.invisibleDots = "..."

  mounted: -> requestAnimationFrame this.update
</script>

<style lang="stylus">
.loading-text
  display flex
  justify-contents center
  align-items center

.invisible-dots
  visibility hidden
</style>
