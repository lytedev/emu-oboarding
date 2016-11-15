Vuex = require 'vuex'

import * as mutationTypes from './mutation-types.coffee'

if not localStorage.pin?
	localStorage.pin = ''

if not localStorage.verified?
	localStorage.verified = false

store = new Vuex.Store
	modules:
		intro:
			state:
				entered: false
				pin: localStorage.pin
				verified: localStorage.verified

			mutations:
				"#{mutationTypes.INTRO_ENTER}": (state, mutation) ->
					state.entered = true

				"#{mutationTypes.INTRO_SET_PIN}": (state, mutation) ->
					state.pin = mutation.pin
					localStorage.pin = state.pin

				"#{mutationTypes.INTRO_SET_VERIFIED}": (state, mutation) ->
					state.verified = mutation.verified
					localStorage.verified = state.verified
		server:
			state:
				status: 'loading'

			mutations:
				"#{mutationTypes.SERVER_ONLINE}": (state, mutation) ->
					state.status = 'online'

				"#{mutationTypes.SERVER_OFFLINE}": (state, mutation) ->
					state.status = 'offline'

				"#{mutationTypes.SERVER_TOGGLE}": (state, mutation) ->
					if state.status == 'online'
						state.status = 'offline'
					else
						state.status = 'online'
		console:
			state:
				queue: ''
				text: ''

			mutations:
				n: ->
					null

	getters:
		serverStatus: (state) -> state.server.status
		consoleQueue: (state) -> state.console.queue
		introPin: (state) -> state.intro.pin
		introEntered: (state) -> state.intro.entered
		introVerified: (state) -> state.intro.verified
		consoleText: (state) -> state.console.text

module.exports = store
