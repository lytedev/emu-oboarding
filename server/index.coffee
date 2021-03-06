express = require 'express'
fs = require 'fs'
pug = require 'pug'
apiRouter = express.Router()

module.exports = (app) ->
	ews = require('express-ws')(app)

	app.use (req, res, next) ->
		next()

	apiRouter.get '/', (req, res) ->
		console.log "API Request!"

	app.use '/api/v1', apiRouter

	apiRouter.ws '/echo', (ws, req) ->
		ws.on 'message', (msg) ->
			ws.send msg

	messageHandlers =
		verifydial: (ws, msg) ->
			console.log "VERIFYDIAL REQUEST", msg
			if msg == '212'
				data =
					verification: 'accepted'
				fs.readFile './data/post-verification-introduction.txt', 'utf8', (err, contents) ->
					data.text = contents
					ws.send JSON.stringify data
			else
				ws.send JSON.stringify { verification: 'denied' }

		dial: (ws, msg) ->
			console.log "DIAL REQUEST", msg
			if msg == '212'
				ws.send JSON.stringify { verification: 'accepted' }
			else
				ws.send JSON.stringify { verification: 'denied' }

	apiRouter.ws '/realtime', (ws, req) ->
		ws.on 'message', (msg) ->
			messageType = msg.split(':', 1)[0]
			messageContents = msg.substring(messageType.length + 1).trim()
			if messageHandlers[messageType]?
				messageHandlers[messageType] ws, messageContents
			else
				console.log "Received Unknown WebSocket Message", msg



