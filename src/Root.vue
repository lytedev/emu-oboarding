<template lang="pug">
#root
	//- .debug {{ debugData }}
	//- transition
	router-view
	slot
</template>

<script lang="coffee">
module.exports =
	computed:
		debugData: ->
			lspin: localStorage.pin
			lsverified: localStorage.verified
			entered: this.$store.getters.introEntered
			pin: this.$store.getters.introPin
			verified: this.$store.getters.introVerified
</script>

<style lang="stylus">
.debug
	position fixed
	bottom 0
	right 0
	padding 0.5rem 1rem
	background #023
	color #fff
	z-index 100000

#root
	color #333
	position relative
	overflow visible
	display flex
	justify-content center
	align-items center
	flex-direction column

.stretchy-flex-column
	text-align center
	display flex
	flex-direction column
	justify-content center
	align-items center
	text-align center
	flex 1

.fade
	transition all 1s ease
	opacity 1

	&.fade-enter, &.fade-leave-active
		opacity 0

.bottomslide
	transition all 1s ease
	position relative
	bottom 0
	flex 1

	&.bottomslide-enter, &.bottomslide-leave-active
		transition all 1s ease
		bottom -40vh
		opacity 0
		flex .00001
		border-width 0
		padding 0

.topinbottomoutslide
	transition all 1s ease
	position relative
	top 0
	flex 1

	&.topinbottomoutslide-enter
		transition all 1s ease
		top -40vh
		opacity 0
		border-width 0
		padding 0
		flex .00001

	&.topinbottomoutslide-leave-active
		transition all 1s ease
		top 40vh
		opacity 0
		flex .00001
		border-width 0
		padding 0

.topslide
	transition all 1s ease
	position relative
	top 0
	flex 1

	&.topslide-enter, &.topslide-leave-active
		top -40vh
		opacity 0
		flex .00001
		border-width 0
		padding 0

.fadeinsizeup
	transition all 1s ease
	flex 1
	opacity 1
	width 100%

	&.fadeinsizeup-enter, &.fadeinsizeup-leave-active
		opacity 0
		flex .00001
		width 0%
		border-width 0
		padding 0

</style>
