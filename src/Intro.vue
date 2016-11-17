<template lang="pug">
.intro.stretchy-flex-column
	transition(name="topslide")
		intro-numpad.flex-hard.topslide(v-if="showNumpad" v-on:pin-submit="pinSubmit" v-bind:can-submit="canSubmit")
	transition(name="fadeinsizeup" appear)
		cinematic-message-list.fadeinsizeup(v-if="showMessages" v-bind:verified="bypass" v-on:dial-operator="showNumpad = !showNumpad" v-bind:callbacks="cmCallbacks")
</template>

<script lang="coffee">
mutationTypes = require '../store/mutation-types.coffee'

module.exports =
	data: ->
		showMessages: false
		showNumpad: false
		bypass: 'loading'
		cmCallbacks:
			dialOperator: =>
				this.addCountdown 1000, =>
					this.showNumpad = !this.showNumpad

		canSubmit: true

	computed:
		pin: -> this.$store.state.intro.pin
		verified: -> this.$store.state.intro.verified
	mixins: [
		require "./mixins/Countdown.coffee"
	]
	components:
		'cinematic-message-list': require './components/CinematicMessageList.vue'
		'intro-numpad': require "./components/IntroNumpad.vue"
	mounted: ->
		# TODO: remove and false
		if not this.$store.getters.introEntered and false
			this.$router.push path: '/'
		else
			# console.log "Intro mounted()"
			this.addCountdown 2000, -> this.showMessages = true

		if this.pin.length > 0 and this.verified == true
			this.bypass = true
		else
			this.bypass = false

		this.startCinematicMessages()
		this.handleVerificationReplies()

	methods:
		handleVerificationReplies: ->
			this.$ws.addEventListener 'message', this.pinSubmitWebsocketReply

		startCinematicMessages: ->
			# output the initial greeting, wait on following lines to check for button
			# having been pressed, server being online, etc.
			this.addCountdown 2000, ->
			this.addCMLine '`callback{"dialOperator"}Running initial systems diagnostics`speed{400}...'

			# promises

			thing = false
			# if the user has entered a pin previously successfully, redirect them to post-verification
			if this.verified == true or true
				this.addCountdown 5000, ->
					this.addCMLine '`speed{0}Returning user detected. `sleep{1000}`speed{50}Redirecting...'
					# TODO: redirect preverified user to final page
			else
				this.addCountdown 5000, ->
					# TODO: Fancier formatting?
					this.addMessage '`speed{50}\nVerifying identity and creating secure connection`speed{1000}...'
					this.addMessage '`speed{0}\nNo compatibe identification peripheral detected.'
					this.addMessage '`sleep{3000}`speed{50}\nAre you sure it is properly connected and setup?'
					this.addMessage '`sleep{2000}\nPlug it in and try again or dial your operator.`callback{"dialOperator1"}'

		addCMLine: (message) ->
			this.$store.commit mutationTypes.SHARED_MESSAGE_LIST_ADD_LINE_TO_QUEUE,
				content: message

		addMessage: (message) ->
			this.$store.commit mutationTypes.SHARED_MESSAGE_LIST_ADD_TO_QUEUE,
				content: message

		pinSubmitWebsocketReply: (ev) ->
			if ev.data?
				data = JSON.parse ev.data
				if data.verification?
					if data.verification == "accepted"
						this.addCMLine "`speed{0}PIN Accepted.`sleep{500}`speed{50} Redirecting..."
						this.$store.commit mutationTypes.INTRO_SET_VERIFIED, { verified: true }
						this.$ws.removeEventListener 'message', this.pinSubmitWebsocketReply
						this.addCountdown 3000, =>
							this.$router.push name: 'terra'
					else
						this.addCMLine "`speed{50}Invalid PIN. Try again."

			this.canSubmit = true

		pinTypeSound: ->
			bp = document.getElementById("button-press")
			bp.pause()
			bp.currentTime = 0
			bp.play()

		pinSubmit: (pin) ->
			# send pin to API
			this.canSubmit = false
			this.$ws.send "dial: #{pin}"
			this.$store.commit mutationTypes.INTRO_SET_PIN, { pin: pin }
			this.addCMLine "Submitted #{new Array(pin.length + 1).join('*')} - Awaiting response`speed{400}..."
			this.$geb.$emit 'clear-pin'

</script>

<style lang="stylus">
@keyframes fadetodarkbg
	0%
		background #fff
	100%
		background #111

.intro
	height 100vh
	width 100vw
	animation fadetodarkbg 1s
	background #111

	.flex-hard
		flex 2

.text
	display flex
	justify-content center
	align-items center

</style>
