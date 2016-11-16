module.exports =
	data: ->
		countdowns: {}
		countdownCounter: 0
		countdownLastTime: 0
	methods:
		updateCountdowns: (timestamp) ->
			requestAnimationFrame this.updateCountdowns

			dt = timestamp - this.countdownLastTime
			if this.countdownLastTime == 0
				this.countdownLastTime = timestamp
				return
			this.countdownLastTime = timestamp

			# run countdowns, keep track of finished ones
			finishedCountdowns = []
			for cd of this.countdowns
				this.countdowns[cd].time -= dt
				if this.countdowns[cd].time < 0
					this.countdowns[cd].callback.apply this
					finishedCountdowns.push cd
			this.removeCountdown cd for cd in finishedCountdowns

		removeCountdown: (key) ->
			delete this.countdowns[key]

		addCountdown: (time, callback, key) ->
			if not key? then key = "__auto_generated_countdown_#{this.countdownCounter++}"
			this.countdowns[key] = { time, callback }

		hastenCountdown: (key, time) ->
			this.modifyCountdownTime key, -time

		delayCountdown: (key, time) ->
			this.modifyCountdownTime key, time

		modifyCountdownTime: (key, time) ->
			this.countdowns[key].time += time

		clearCountdowns: ->
			this.removeCountdown cd for cd in Object.keys this.countdowns

	mounted: ->
		requestAnimationFrame this.updateCountdowns
