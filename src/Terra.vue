<template lang="pug">
#Terra
	transition(name="fadeinsizeup" appear)
		cinematic-message-list.fadeinsizeup
</template>

<script lang="coffee">
mutationTypes = require '../store/mutation-types.coffee'

module.exports =
	mixins: [
		require "./mixins/Countdown.coffee"
	]
	components:
		'cinematic-message-list': require './components/CinematicMessageList.vue'

	data: ->
		reload: true
		consoleSpeed: (1 / 60) * 1000

	computed:
		entered: -> this.$store.state.intro.entered
		pin: -> this.$store.state.intro.pin
		verified: -> this.$store.state.intro.verified
		message: -> this.$store.state.intro.greeting

	mounted: ->
		if this.message == '' or not this.message then return this.$router.replace '/'

		this.addCountdown 2000, =>
			this.addMessage this.message

	methods:
		addMessage: (message) ->
			this.$store.commit mutationTypes.SHARED_MESSAGE_LIST_ADD_TO_QUEUE,
				content: "\n" + message
</script>

<style lang="stylus">
</style>
