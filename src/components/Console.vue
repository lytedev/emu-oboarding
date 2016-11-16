<template lang="pug">
ul.console
	li(v-for="message in messages") {{ message.text }}
</template>

<script lang="coffee">
mutationTypes = require '../../store/mutation-types.coffee'

clickAudio = document.getElementById "click"
clickAudio.volume = 0.2

module.exports =
	data: ->
		s: 9
</script>

<style lang="stylus">

.console
	width 100%
	flex-grow 1
	min-width 20rem
	position relative

	&.big
		position fixed
		top 0
		bottom 0
		left 0
		right 0
		font-family monospace

		textarea
			position fixed
			top 0
			bottom 0
			left 0
			right 0
			border 0
			border-radius 0
			max-width 100%
			max-height 100%
			height 100%
			width 100%

	textarea
		resize none
		width 100%
		height 8.5rem
		line-height 1.5rem
		overflow-y hidden
		overflow-wrap break-word
		word-wrap break-word
		word-break break-all
		word-break break-word
		hyphens auto
		color #fff

@keyframes slideupout
	0%
		max-height 10rem
		top 0
		opacity 1
	20%
		top -3rem
	60%
		top 200vh
	100%
		max-height 0rem
		opacity 0
		top 200vh

@keyframes slideupin
	0%
		max-height 0
		opacity 0
		top 200vh
	20%
		top 200vh
	60%
		top -3rem
	100%
		max-height 10rem
		top 0
		opacity 1

.slideupin-enter-active
	top 0
	animation slideupin 0.6s

.slideupin-leave-active
	background-color #f00
	top 0
	animation slideupout 0.6s

.slideupin-enter
.slideupin-leave-active
	position relative
	top 200vh

</style>
