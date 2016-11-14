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
				"#{mutationTypes.CONSOLE_ADD_LINE_TO_QUEUE}": (state, mutation) ->
					if state.text != '' or state.queue != ''
						mutation.text = "\n" + mutation.text
					state.queue += mutation.text

				"#{mutationTypes.CONSOLE_ADD_TO_QUEUE}": (state, mutation) ->
					state.queue += mutation.text

				"#{mutationTypes.CONSOLE_UPDATE_CHARS}": (state, mutation) ->
					state.text += state.queue.substring 0, mutation.chars
					state.queue = state.queue.substring mutation.chars

				"#{mutationTypes.CONSOLE_DELETE_QUEUE_CHARS}": (state, mutation) ->
					state.queue = state.queue.substring(0, state.queue.length - mutation.chars)

				"#{mutationTypes.CONSOLE_DELETE_CHARS}": (state, mutation) ->
					state.text = state.text.substring(0, state.text.length - mutation.chars)

				"#{mutationTypes.CONSOLE_CLEAR_TEXT}": (state) -> state.text = ''
				"#{mutationTypes.CONSOLE_CLEAR_QUEUE}": (state) -> state.queue = ''

	getters:
		serverStatus: (state) -> state.server.status
		consoleQueue: (state) -> state.console.queue
		introPin: (state) -> state.intro.pin
		introEntered: (state) -> state.intro.entered
		introVerified: (state) -> state.intro.verified
		consoleText: (state) -> state.console.text

module.exports = store
