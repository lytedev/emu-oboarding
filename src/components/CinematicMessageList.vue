<template lang="pug">
.cinematic-message-list-container
	ul.message-list(v-bind:class="{ 'has-caret': caret }")
		li(v-for="message in messages") {{ message.text }}
</template>

<script lang="coffee">
mutationTypes = require '../../store/mutation-types.coffee'

clickAudio = document.getElementById "click"
clickAudio.volume = 0.2

RPGText = require './RPGText.coffee'

module.exports =
	mixins: [
		require '../mixins/Countdown.coffee'
	]

	data: ->
		lastTime: 0
		caretTimer: 0
		caretPeriod: 400
		rpgText: new RPGText('`', 50)

	computed:
		caret: ->
			this.rpgText.caret

		messages: ->
			this.rpgText.messages

	methods:
		update: (timestamp) ->
			requestAnimationFrame this.update # queue next update
			this.rpgText.update timestamp # update messages

	mounted: ->
		this.rpgText = new RPGText('`', 50)
		console.log "CinematicMessageList mounted()"
		this.addCountdown 2000, ->
			console.log "Queueing test lines..."
			this.rpgText.addMessage "This is a test line of sufficient length."
			this.rpgText.queueString "This is the third line. It is really really really really really really really really really really really really really really really really really really really really long"
			this.rpgText.queueString "\nThis is the third line. It is really areally really really really really really really really really really really really really really really really really really really long"

			this.updateText = true
		requestAnimationFrame this.update

</script>

<style lang="stylus">
@import '../styles/_variables.styl'

.cinematic-message-list-container
	list-style none
	padding 0.25em
	text-align left
	font-size 60%
	color #fff
	max-width 600px
	width 100%

	ul.message-list
		list-style none
		box-sizing border-box
		background #222
		border solid 0.1em #444
		border-radius 0.1em
		width 100%
		height 100%
		margin 0
		padding 0.25em

		&.has-caret
			li:last-of-type::after
				overflow visible
				width 0
				content '|'

		li
			padding-left 1em
			text-indent -1em
			
	.caret
		color $brand-primary-color
</style>
