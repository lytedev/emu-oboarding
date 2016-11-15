<template lang="pug">
.loading.stretchy-flex-column.open-bottom(v-on:click="showLoadingText = !showLoadingText")
  //- .debug {{ loading }}, {{ showLogo }}, {{ showLoadingText }}
  transition(name="topslide")
    logo.topslide(v-show="showLogo")
  transition(name="topslide")
    loading-text.topslide(v-show="showLoadingText" v-bind:is-loading="loading" v-bind:text="loadText")
  transition(name="bottomslide")
    a.btn.bottomslide(v-show="showEnterButton" v-on:click="gotoVerification") Enter
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

    gotoVerification: ->
      if this.status != 'online' then return
      if not this.online then return
      if not this.showEnterButton then return

      $router.go

  mounted: ->
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
      this.loadText = val.toString().toUpperCase()
      this.online = true
      this.countdowns.hideLoading =
        time: 2000
        callback: -> this.showLoadingText = false
      this.countdowns.enterButton =
        time: 4000
        callback: -> this.showEnterButton = true
    , (val) ->
      this.loading = false
      this.loadText = val.toString().toUpperCase()
      this.online = false
      this.countdowns.goOffline =
        time: this.lastTime + 2000
        callback: ->
          this.$router.go
            name: 'offline'

    # initialize our countdowns
    this.countdowns.loadingText =
      time: 1000
      callback: -> this.showLoadingText = true
    this.countdowns.loadingIndicator =
      time: 2000
      callback: -> this.loading = true
    this.countdowns.logo =
      time: 3000
      callback: -> this.showLogo = true

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
  position relative
  max-height 100vh
  overflow hidden
  min-width 280px
  transition all 1s ease
  border solid 0.1em #ccc
  padding 0.5em
  animation borderfadein 2s
  border-radius 0.2em
</style>
