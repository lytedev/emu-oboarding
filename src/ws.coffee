store = require '../store/index.coffee'
mutationTypes = require '../store/mutation-types.coffee'

module.exports = (Vue, options) ->
	ws = new WebSocket "ws://#{window.location.hostname}:8080/api/v1/realtime"
	ws.onopen = (ev) ->
		console.log "WS Open", ev
		store.commit mutationTypes.SERVER_ONLINE
	ws.onmessage = (ev) ->
		console.log "WS Message", ev
		store.commit mutationTypes.SERVER_ONLINE
	ws.onclose = (ev) ->
		console.log "WS Close", ev
		if ev.code == 3001
			ws = null
		else
			ws = null
		store.commit mutationTypes.SERVER_OFFLINE
	ws.onerror = (ev) ->
		if ws.readyState == 1
			store.commit mutationTypes.SERVER_OFFLINE
			# console.log "Normal WS Error", ev.type, ev
			null

	osend = ws.send
	ws.send = (msg) ->
		osend.apply ws, [ msg ]

	Vue.prototype.$ws = ws
