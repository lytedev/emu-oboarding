<template lang="pug">
.intro.stretchy-flex-column(v-bind:style="{ 'backgroundColor': backgroundColor }")
	//- a(v-on:click="/* toTerra */showNumpad = !showNumpad" style="flex:1;") Onward!
	transition(name="topslide")
		intro-numpad.topslide(v-if="showNumpad" v-on:pin-submit="pinSubmit" v-bind:can-submit="canSubmit" v-on:pin-input="pinInput")
	transition(name="fadeinsizeup" appear)
		cinematic-message-list.fadeinsizeup(v-if="showMessages" v-bind:verified="bypass" v-on:dial-operator="showNumpad = !showNumpad" v-bind:callbacks="cmCallbacks" v-on:messages-updating-change="messagesUpdating")
</template>

<script lang="coffee">
mutationTypes = require '../store/mutation-types.coffee'

module.exports =
	data: ->
		backgroundColor: '#111'
		showMessages: false
		showNumpad: false
		bypass: 'loading'
		cmCallbacks:
			successSound: =>
				success = document.getElementById('success-sound')
				success.volume = 0.4
				success.play()
			errorSound: =>
				error = document.getElementById('error-sound')
				error.volume = 0.4
				error.play()
			dialOperator: =>
				this.showNumpad = true

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
		if not this.$store.getters.introEntered
			this.$router.replace '/'
		else
			# console.log "Intro mounted()"
			this.addCountdown 2000, -> this.showMessages = true

			if this.pin != '' and this.pin != false and this.verified == true
				this.bypass = true
			else
				this.bypass = false

			this.startCinematicMessages()
			this.handleVerificationReplies()
			requestAnimationFrame this.update

	methods:
		update: ->
			requestAnimationFrame this.update

		messagesUpdating: (val) ->
			typing = document.getElementById('click')
			if val == true
				typing.volume = 0.2
				typing.muted = false
			else
				typing.volume = 0
				typing.muted = true
				
		pinInput: ->
			buttonPress = document.getElementById('button-press')
			buttonPress.volume = 0.4
			buttonPress.pause()
			buttonPress.currentTime = 0
			buttonPress.play()

		handleVerificationReplies: ->
			this.$ws.addEventListener 'message', this.pinSubmitWebsocketReply

		startCinematicMessages: ->
			# output the initial greeting, wait on following lines to check for button
			# having been pressed, server being online, etc.
			this.$store.commit mutationTypes.SHARED_MESSAGE_LIST_CLEAR_QUEUE
			this.addCountdown 2000, ->
				this.addCMLine 'Checking runtime and subsystems\' status`speed{400}...'

			# TODO: promises?

			# if the user has entered a pin previously successfully, redirect them to post-verification
			if this.bypass
				this.addCountdown 5000, ->
					this.addCMLine '`speed{0}Returning user detected. `sleep{1000}`speed{50}Redialing operator...'
					this.addCountdown 8000, =>
						this.pinSubmit this.pin.toString()
			else
				this.addCountdown 5000, ->
					# TODO: Fancier formatting?
					this.addMessage '`speed{50}\nVerifying identity and creating secure connection`speed{1000}...'
					this.addMessage '`class{"warning"}`speed{0}\nNo compatibe identification peripheral detected.'
					this.addMessage '`sleep{3000}`speed{50}\nAre you sure it is properly connected and setup?'
					this.addMessage '`sleep{2000}\nVerify the connection and try again or dial your operator.`sleep{3000}`callback{"dialOperator"}'

		addCMLine: (message) ->
			this.$store.commit mutationTypes.SHARED_MESSAGE_LIST_ADD_LINE_TO_QUEUE,
				content: message

		addMessage: (message) ->
			this.$store.commit mutationTypes.SHARED_MESSAGE_LIST_ADD_TO_QUEUE,
				content: message

		toTerra: ->
			console.log "from toTerra()"
			this.showNumpad = false
			this.addCountdown 2000, =>
				this.showMessages = false
				this.backgroundColor = "#fff"
			this.addCountdown 4000, =>
				this.$router.push name: 'terra'

		pinSubmitWebsocketReply: (ev) ->
			if ev.data?
				data = JSON.parse ev.data
				if data.verification?
					if data.verification == "accepted"
						this.addCMLine '`speed{0}PIN Accepted.`callback{"successSound"}`sleep{500}`speed{50} Redirecting...'
						this.$store.commit mutationTypes.INTRO_SET_VERIFIED, { verified: true }
						this.$store.commit mutationTypes.INTRO_SET_GREETING_MESSAGE, { message: data.message }
						this.$ws.removeEventListener 'message', this.pinSubmitWebsocketReply
						this.addCountdown 5000, =>
							console.log "toTerra()"
							this.toTerra()
					else
						this.addCMLine '`speed{50}Invalid PIN.`callback{"errorSound"} Try again.'

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
			this.$store.commit mutationTypes.INTRO_SET_PIN, { pin: parseFloat pin }
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
	color #fff
	height 100vh
	width 100vw
	animation fadetodarkbg 1s
	transition background 1s ease
	background #111

.text
	display flex
	justify-content center
	align-items center

</style>
