<template lang="pug">
.intro.stretchy-flex-column
	transition(name="fadeinsizeup" appear)
		cinematic-message-list.fadeinsizeup(v-if="showMessages")
</template>

<script lang="coffee">
module.exports =
	data: ->
		showMessages: false
	mixins: [
		require "./mixins/Countdown.coffee"
	]
	components:
		'cinematic-message-list': require './components/CinematicMessageList.vue'
	mounted: ->
		console.log "Intro mounted()"
		this.addCountdown 2000, -> this.showMessages = true
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

.text
	display flex
	justify-content center
	align-items center
</style>
