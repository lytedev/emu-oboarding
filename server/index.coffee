express = require 'express'
apiRouter = express.Router()

module.exports = (app) ->
	# ews = require('express-ws')(app)

	app.use (req, res, next) ->
		next()

	apiRouter.get '/', (req, res) ->
		console.log "API Request!"

	app.use '/api/v1', apiRouter



