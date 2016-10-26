ws = new WebSocket "ws://localhost:8080"
ws.onopen = (ev) ->
	console.log 'Connected'
ws.onmessage = (ev) ->
	console.log ev
ws.onclose = (ev) ->
	if ev.code == 3001
		console.log "3001 Closed"
		ws = null
	else
		ws = null
		console.log "WS Connection Error"
		ev.preventDefault()
		return false
ws.onerror = (ev) ->
	if ws.readyState == 1
		console.log "Normal WS Error", ev.type, ev

