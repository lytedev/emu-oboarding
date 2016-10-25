Vuex = require 'vuex'

import { CONSOLE_ADD_LINE_TO_QUEUE, CONSOLE_UPDATE_CHARS, CONSOLE_DELETE_CHARS, CONSOLE_CLEAR_TEXT } from './mutation-types.coffee'

store = new Vuex.Store
	state:
		queue: 0
	modules:
		console:
			state:
				queue: ''
				text: ''
			mutations:
				"#{CONSOLE_ADD_LINE_TO_QUEUE}": (state, mutation) ->
					if state.text != ''
						mutation.text = "\n" + mutation.text
					state.queue += mutation.text
				"#{CONSOLE_UPDATE_CHARS}": (state, mutation) ->
					state.text += state.queue.substring 0, mutation.chars
					state.queue = state.queue.substring mutation.chars
				"#{CONSOLE_DELETE_CHARS}": (state, mutation) ->
					state.text = state.text.substring(0, state.text.length - mutation.chars)
				"#{CONSOLE_CLEAR_TEXT}": (state) ->
					state.text = ''
	getters:
		queue: (state) ->
			state.console.queue
		text: (state) ->
			state.console.text
	mutations:
		increment: (state) ->
			state.count++

module.exports = store
