<template lang="pug">
transition(appear v-on:enter="load")
  #Terra
</template>

<script lang="coffee">
module.exports =
  methods:
    verifyPin: ->

    load: ->
      console.log "Terra Load"

      if not this.$store.state.intro.entered and this.$store.state.intro.pin == ''
        this.$router.replace '/'
        return

      # listen for pin verification
      that = this
      this.$ws.addEventListener 'message', (ev) ->
        if ev.data?
          data = JSON.parse ev.data
          if data.verification?
            if data.verification == "accepted"
              that.continueLoad data
            else
              this.$router.replace '/'
              return

      # send pin
      this.$ws.send 'verifydial: ' + this.$store.state.intro.pin

    continueLoad: (data) ->
      console.log data

</script>

<style lang="stylus">
</style>
