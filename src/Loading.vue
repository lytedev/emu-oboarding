<template lang="pug">
.loading.stretchy-flex-column
  //- .debug {{ loading }}, {{ showLogo }}, {{ showLoadingText }}
  transition(name="topslide" appear)
    logo.topslide(v-show="showLogo")
  transition(name="topinbottomoutslide" appear)
    loading-text.topinbottomoutslide(v-show="showLoadingText" v-bind:is-loading="loading" v-bind:text="loadText")
  transition(name="bottomslide")
    a.btn.bottomslide(v-show="showEnterButton" v-on:click="gotoVerification" href="#") Enter
</template>

<script lang="coffee">
mutationTypes = require '../store/mutation-types.coffee'

fakeLoadTime = 5000

module.exports =
  data: ->
    showLogo: false
    showLoadingText: false
    showEnterButton: false
    loadText: "Loading"
    loading: false
    lastTime: 0
    online: 'loading'

    leaving: false

    countdowns: {}

  components:
    'loading-text': require './components/LoadingText.vue'
    'logo': require './components/Logo.vue'

  computed:
    status: ->
      this.$store.state.server.status

  methods:
    update: (timestamp) ->
      dt = timestamp - this.lastTime
      this.lastTime = timestamp

      # run countdowns
      finishedCountdowns = []
      for cd of this.countdowns
        this.countdowns[cd].time -= dt
        if this.countdowns[cd].time < 0
          this.countdowns[cd].callback.apply this
          finishedCountdowns.push cd

      for cd in finishedCountdowns
        delete this.countdowns[cd]

      requestAnimationFrame this.update

    gotoVerification: (e, done) ->
      console.log "gotoVerification()"
      if not this.leaving
        if this.status != 'online' then return
        if not this.online then return
        if not this.showEnterButton then return

        this.showEnterButton = false
        this.showLogo = false
        this.leaving = true
        this.countdowns.verifyAgain =
          time: 1000
          callback: =>
            this.gotoVerification()
      else
        if this.status != 'online' then return
        if not this.online then return

        this.$router.push
          name: 'verification'

  mounted: ->
    window.loadingComponent = this

    # reset our data to defaults in case of weird refresh
    this.showLogo = false
    this.showLoadingText = false
    this.showEnterButton = false
    this.loadText = "Loading"
    this.loading = false
    this.online = "loading"

    if this.status != "loading"
      this.online = if this.status == "online" then true else false

    # create a promise for checking on server status
    statusPromise = new Promise (resolve, reject) =>
      if this.status == 'loading'
        this.$watch 'status', (val, old) =>
          if val == 'online' then resolve(val) else reject(val)
      else
        if this.status == 'online' then resolve(this.status) else reject(this.status)


    # create a promise for the fake load time
    fakeLoadPromise = new Promise (resolve, reject) =>
      setTimeout ->
        resolve(true)
      , fakeLoadTime

    # we'll use a promise here to handle the last of the other promises
    p = new Promise (resolve, reject) =>
      sp = 'loading'
      fl = 'loading'
      checkDone = =>
        if sp == 'loading' or fl == 'loading' then return
        if not sp then reject('offline') else resolve('online')

      statusPromise.then (val) =>
        sp = true
        checkDone()
      , (val) =>
        sp = false
        checkDone()

      fakeLoadPromise.then (val) =>
        fl = true
        checkDone()

    p.then (val) =>
      this.loading = false
      this.loadText = val.toString()
      # uppercase first character
      this.loadText = this.loadText.charAt(0).toUpperCase() + this.loadText.slice(1)
      this.online = true
      this.countdowns.hideLoading =
        time: 2000
        callback: -> this.showLoadingText = false
      this.countdowns.enterButton =
        time: 4000
        callback: -> this.showEnterButton = true
    , (val) ->
      this.loading = false
      this.loadText = val.toString()
      # uppercase first character
      this.loadText = this.loadText.charAt(0).toUpperCase() + this.loadText.slice(1)
      this.online = false
      this.countdowns.goOffline =
        time: this.lastTime + 2000
        callback: ->
          this.$router.go
            name: 'offline'

    # initialize our countdowns
    this.countdowns.loadingText =
      time: 1000
      callback: ->
        this.showLoadingText = true
    this.countdowns.openTop =
      time: 1200
      callback: ->
        this.openTop = true
    this.countdowns.closeTop =
      time: 1500
      callback: ->
        this.openTop = false
    this.countdowns.loadingIndicator =
      time: 2000
      callback: -> this.loading = true
    this.countdowns.logo =
      time: 3000
      callback: -> this.showLogo = true

    debug = false
    if debug
      this.countdowns = {}
      this.showLoadingText = false
      this.showLogo = true
      this.showEnterButton = true

    # watch for a status
    requestAnimationFrame this.update
</script>

<style lang="stylus">

@keyframes borderfadein
  0%
    border-color transparent
  50%
    border-color transparent
  100%
    border-color #ccc

.loading
  max-height 100vh
  overflow visible
  min-width 280px
  max-width 400px
  width 5%
  padding 0.5em
  animation borderfadein 1.5s
  border-radius 0.2em
  height 6em

  div, a
    // display none
</style>
