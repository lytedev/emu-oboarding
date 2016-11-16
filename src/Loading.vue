<template lang="pug">
.loading.stretchy-flex-column
	//- .debug {{ loading }}, {{ showLogo }}, {{ showLoadingText }}
	transition(name="topslide" appear)
		logo.topslide(v-show="showLogo")
	transition(name="topinbottomoutslide" appear)
		loading-text.topinbottomoutslide(v-show="showLoadingText" v-bind:is-loading="loading" v-bind:text="loadText")
	transition(name="bottomslide")
		a.btn.bottomslide.enter-button(v-show="showEnterButton" v-on:click="gotoVerification" href="#") Enter
</template>

<script lang="coffee">
mutationTypes = require '../store/mutation-types.coffee'

fakeLoadTime = 5000

module.exports =
	mixins: [
		require "./mixins/Countdown.coffee"
	]
	data: ->
		showLogo: false
		showLoadingText: false
		showEnterButton: false
		loadText: "Loading"
		loading: false
		lastTime: 0
		online: 'loading'

		leaving: false

	components:
		'loading-text': require './components/LoadingText.vue'
		'logo': require './components/Logo.vue'

	computed:
		status: ->
			this.$store.state.server.status

	methods:
		gotoVerification: (e, done) ->
			if not this.leaving
				if this.status != 'online' then return
				if not this.online then return
				if not this.showEnterButton then return

				this.showEnterButton = false
				this.showLogo = false
				this.leaving = true
				this.addCountdown 2000, ->
					this.gotoVerification()

				console.log "Hit Button"
				# TODO: mutate store saying we hit the button
				# TODO: fire user event required functions

				e.preventDefault?()
			else
				if this.status != 'online' then return
				if not this.online then return

				console.log "Navigating to verification!"

				this.$router.push
					name: 'verification'

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
			this.loadText = val.toString()
			# uppercase first character
			this.loadText = this.loadText.charAt(0).toUpperCase() + this.loadText.slice(1)
			this.online = true
			this.addCountdown 2000, -> this.showLoadingText = false
			this.addCountdown 4000, -> this.showEnterButton = true
		, (val) ->
			this.loading = false
			this.loadText = val.toString()
			# uppercase first character
			this.loadText = this.loadText.charAt(0).toUpperCase() + this.loadText.slice(1)
			this.online = false
			this.addCountdown this.lastTime + 2000, -> this.$router.go name: 'offline'

		# initialize our countdowns
		this.addCountdown 1000, -> this.showLoadingText = true
		this.addCountdown 1200, -> this.openTop = true
		this.addCountdown 1500, -> this.openTop = false
		this.addCountdown 2000, -> this.loading = true
		this.addCountdown 3000, -> this.showLogo = true

		debug = true
		if debug
			this.clearCountdowns()
			this.showLoadingText = false
			this.showLogo = true
			this.showEnterButton = true
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

	.enter-button
		font-size 175%

	div, a
		// display none
</style>
