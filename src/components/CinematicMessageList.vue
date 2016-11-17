<template lang="pug">
.cinematic-message-list-container
	//- .debug {{ verified }}
	ul.message-list(v-bind:class="{ 'has-caret': caret }")
		li(v-for="message in messages" v-html="message.text")
</template>

<script lang="coffee">
mutationTypes = require '../../store/mutation-types.coffee'

RPGText = require './RPGText.coffee'

module.exports =
	props: ['verified', 'callbacks']

	mixins: [
		require '../mixins/Countdown.coffee'
	]

	data: ->
		lastTime: 0
		caretTimer: 0
		caretPeriod: 400
		rpgText: new RPGText('`', 50)
		lastLength: 0
		lastUpdating: false

	computed:
		caret: ->
			this.rpgText.caret
		messages: ->
			this.rpgText.messages
		sharedQueue: ->
			this.$store.state.sharedMessageList.queue
	watch:
		sharedQueue: (val, old) ->
			if val == '' then return
			this.rpgText.queueString val
			this.$store.commit mutationTypes.SHARED_MESSAGE_LIST_CLEAR_QUEUE
			
	methods:
		update: (timestamp) ->
			requestAnimationFrame this.update # queue next update
			this.rpgText.update timestamp # update messages
			msgList = this.$el.childNodes[0]
			msgList.scrollTop = msgList.scrollHeight

			if this.rpgText.isUpdating != this.lastUpdating
				this.$emit 'messages-updating-change', this.rpgText.isUpdating
				
			this.lastUpdating = this.rpgText.isUpdating

	mounted: ->
		this.clearCountdowns()

		# if the user hasn't clicked the enter button, send them back home
		this.rpgText = new RPGText('`', 50)
		this.rpgText.callbacks = this.callbacks
		# console.log "CinematicMessageList mounted()"

		requestAnimationFrame this.update

</script>

<style lang="stylus">
@import '../styles/_variables.styl'

.cinematic-message-list-container
	list-style none
	padding 0.125em
	text-align left
	color #fff
	max-width 600px
	width 100%
	overflow hidden

	ul.message-list
		font-size 50%
		list-style none
		box-sizing border-box
		background #222
		border solid 0.2em #444
		border-radius 0.2em
		width 100%
		height 100%
		margin 0
		padding 0.25em
		overflow hidden

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
