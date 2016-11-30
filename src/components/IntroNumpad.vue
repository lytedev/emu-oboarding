<template lang="pug">
.intro-numpad-container
	.intro-numpad
		input.pin-input(type="text" title="Enter the secure PIN using the numpad below" v-bind:value="pin" placeholder="Enter PIN" disabled)
		a.number-input.btn(v-html="v" v-for="v in values" v-on:click="addToPin(v)")
</template>

<script lang="coffee">
mutationTypes = require '../../store/mutation-types.coffee'

module.exports =
	props:
		canSubmit:
			default: true
			type: Boolean
	data: ->
		pin: ''

	computed:
		values: ->
			vals = '789456123'
			va = []
			for v in vals
				va.push v
			va.push '<i data-numpadaction="pinBackspace" title="Backspace" class="material-icons">&#xE166;</i>'
			va.push '0'
			va.push '<i data-numpadaction="pinSubmit" title="Submit" class="material-icons">&#xE255;</i>'
			return va

	mounted: ->
		this.$geb.$on 'clear-pin', =>
			this.pin = ''

	methods:
		addToPin: (v) ->
			inputted = ''
			if v.length == 1
				this.pin += v
				inputed = v
			else
				action = /data-numpadaction="(.*?)"/.exec(v)[1]
				this[action].apply this
				inputed = action + "()"
			this.$emit 'pin-input', inputted

		pinBackspace: ->
			this.pin = this.pin.substring(0, this.pin.length - 1)

		pinSubmit: ->
			if not this.canSubmit then return
			if this.pin == '' then return

			this.$emit 'pin-submit', this.pin
</script>

<style lang="stylus">
@import '../styles/_variables.styl'

.intro-numpad-container
	padding 0.125em
	padding-bottom 0
	display flex
	width 60%
	max-width 500px
	justify-content center
	flex-wrap wrap
	align-items center

	.intro-numpad
		display flex
		justify-content space-between
		align-items space-between
		flex-wrap wrap
		/* max-width 600px
		text-align center
		list-style none
		box-sizing border-box
		background #222
		border solid 0.1em #444
		border-radius 0.1em
		width 100%
		margin 0
		padding 0.25em
		padding-bottom 0 */

		.pin-input
			text-align center
			width 100%
			margin-bottom 0.25em

		.number-input
			width 30%
			margin-bottom 0.25em
			cursor pointer

	&.topslide
		max-height 100%
		flex 3

</style>
