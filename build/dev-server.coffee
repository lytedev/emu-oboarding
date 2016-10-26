path = require('path')
express = require('express')
webpack = require('webpack')
opn = require('opn')
proxyMiddleware = require('http-proxy-middleware')

config = require('../config')

if not process.env.NODE_ENV?
  process.env.NODE_ENV = config.dev.env.NODE_ENV
port = process.env.PORT or config.dev.port

webpackConfig = if process.env.NODE_ENV == 'testing' then require('./webpack.prod.conf') else require('./webpack.dev.conf')

# Define HTTP proxies to your custom API backend
# https://github.com/chimurai/http-proxy-middleware
proxyTable = config.dev.proxyTable

app = express()
compiler = webpack(webpackConfig)

devMiddleware = {}
if process.env.NODE_ENV == config.dev.env.NODE_ENV
	devMiddleware = require('webpack-dev-middleware')(compiler,
		publicPath: webpackConfig.output.publicPath
		stats:
			colors: true
			chunks: false)

# force page reload when html-webpack-plugin template changes
hotMiddleware = {}
if process.env.NODE_ENV == config.dev.env.NODE_ENV
	hotMiddleware = require('webpack-hot-middleware')(compiler)
	compiler.plugin 'compilation', (compilation) ->
		compilation.plugin 'html-webpack-plugin-after-emit', (data, cb) ->
			hotMiddleware.publish action: 'reload'
			cb()
			return
		return

# proxy api requests
Object.keys(proxyTable).forEach (context) ->
  options = proxyTable[context]
  if typeof options == 'string'
    options = target: options
  app.use proxyMiddleware(context, options)
  return

# handle fallback for HTML5 history API
app.use require('connect-history-api-fallback')()

# serve webpack bundle output
if process.env.NODE_ENV == config.dev.env.NODE_ENV
	app.use devMiddleware

# enable hot-reload and state-preserving compilation error display
if process.env.NODE_ENV == config.dev.env.NODE_ENV
	app.use hotMiddleware

# serve pure static assets
staticPath = path.posix.join(config.dev.assetsPublicPath, config.dev.assetsSubDirectory)
app.use staticPath, express.static('./static')

require('../server/index.coffee')(app)

module.exports = app.listen port, (err) ->
  if err
    console.log err
    return
  uri = 'http://localhost:' + port
  console.log 'Listening at ' + uri + '\n'
  opn uri
  return
