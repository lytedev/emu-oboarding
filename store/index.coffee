Vuex = require 'vuex'

import * as mutationTypes from './mutation-types.coffee'

if not localStorage.pin?
	localStorage.pin = '""'
if not localStorage.verified?
	localStorage.verified = "false"
if not localStorage.colors?
	localStorage.colors = '{}'

store = new Vuex.Store
	modules:
		misc:
			state:
				colors:
					bg: '#fff'
		intro:
			state:
				entered: false
				pin: JSON.parse localStorage.pin
				verified: JSON.parse localStorage.verified
				greeting: ''

			mutations:
				"#{mutationTypes.INTRO_SET_GREETING_MESSAGE}": (state, mutation) ->
					state.greeting = mutation.message

				"#{mutationTypes.INTRO_ENTER}": (state, mutation) ->
					state.entered = true

				"#{mutationTypes.INTRO_SET_PIN}": (state, mutation) ->
					state.pin = mutation.pin
					localStorage.pin = JSON.stringify state.pin

				"#{mutationTypes.INTRO_SET_VERIFIED}": (state, mutation) ->
					state.verified = mutation.verified
					localStorage.verified = JSON.stringify state.verified
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
		sharedMessageList:
			state:
				queue: ''

			mutations:
				"#{mutationTypes.SHARED_MESSAGE_LIST_ADD_TO_QUEUE}": (state, mutation) ->
					state.queue += mutation.content
				"#{mutationTypes.SHARED_MESSAGE_LIST_ADD_LINE_TO_QUEUE}": (state, mutation) ->
					state.queue += "\n" + mutation.content
				"#{mutationTypes.SHARED_MESSAGE_LIST_CLEAR_QUEUE}": (state, mutation) ->
					state.queue = ''

	getters:
		serverStatus: (state) -> state.server.status
		consoleQueue: (state) -> state.console.queue
		introPin: (state) -> state.intro.pin
		introEntered: (state) -> state.intro.entered
		introVerified: (state) -> state.intro.verified
		consoleText: (state) -> state.console.text

module.exports = store
