Vuex = require 'vuex'

import * as mutationTypes from './mutation-types.coffee'

store = new Vuex.Store
	modules:
		intro:
			state:
				entered: false
				pin: ''
			mutations:
				"#{mutationTypes.INTRO_ENTER}": (state, mutation) ->
					state.entered = true
				"#{mutationTypes.INTRO_SET_PIN}": (state, mutation) ->
					state.pin = mutation.pin
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
				"#{mutationTypes.CONSOLE_DELETE_CHARS}": (state, mutation) ->
					state.text = state.text.substring(0, state.text.length - mutation.chars)
				"#{mutationTypes.CONSOLE_CLEAR_TEXT}": (state) ->
					state.text = ''
				"#{mutationTypes.CONSOLE_CLEAR_QUEUE}": (state) ->
					state.queue = ''
	getters:
		status: (state) ->
			state.server.status
		queue: (state) ->
			state.console.queue
		introEntered: (state) ->
			state.intro.entered
		text: (state) ->
			state.console.text

module.exports = store
