<template lang="pug">
#Terra
	//- transition(name="fadeinsizeup" appear)
		cinematic-message-list.fadeinsizeup
</template>

<script lang="coffee">
mutationTypes = require '../store/mutation-types.coffee'

module.exports =
	components:
		'cinematic-message-list': require './components/CinematicMessageList.vue'
	data: ->
		reload: true
		consoleSpeed: (1 / 60) * 1000
	methods:
		continueLoad: (data) ->
			console.log data

			that = this
			offset = 1000
			offsetPerChar = (1 / 60) * 1000

			this.$store.commit mutationTypes.CONSOLE_ADD_LINE_TO_QUEUE, { text: data.text }

	mounted: ->
		if not this.$store.state.intro.entered or this.$store.state.intro.pin == ''
			this.$router.replace '/'
			return

		# listen for pin verification
		that = this
		onMessage = (ev) ->
			if ev.data?
				data = JSON.parse ev.data
				if data.verification?
					that.$ws.removeEventListener 'message', onMessage
					if data.verification == 'accepted'
						that.continueLoad data
					else
						that.$store.commit mutationTypes.INTRO_SET_VERIFIED, { verified: false }
						that.$store.commit mutationTypes.INTRO_SET_PIN, { pin: '' }
						that.$router.replace '/'
						return

		this.$ws.addEventListener 'message', onMessage
		# send pin
		this.$ws.send 'verifydial: ' + this.$store.state.intro.pin

</script>

<style lang="stylus">
</style>
