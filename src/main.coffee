MainStyles = require './styles/main.styl'

Vue = require 'vue'
Vuex = require 'vuex'
VueRouter = require 'vue-router'

Vue.config.debug = true

Vue.use VueRouter
Vue.use Vuex

# our websocket plugin uses the store, so it must come after we install the vuex
# plugin
ws = require './ws.coffee'
Vue.use ws

Intro = require './Intro.vue'
Loading = require './Loading.vue'
Offline = require './Offline.vue'
Root = require './Root.vue'
Terra = require './components/Terra.vue'
store = require '../store/index.coffee'

routes = [
	{
		path: '/'
		component: Root
		children: [
			{ name: 'loading', path: '/', component: Loading }
			{ name: 'verification', path: '/verification', component: Intro }
			{ name: 'offline', path: '/offline', component: Offline }
			{ name: 'terra', path: '/Terra', component: Terra }
		]
	}
]

router = new VueRouter
	mode: 'history'
	routes: routes

app = new Vue
	router: router
	store: store
.$mount '#mount'

require './analytics.coffee'
