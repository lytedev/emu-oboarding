MainStyles = require './styles/main.styl'

Vue = require 'vue'
Vuex = require 'vuex'
VueRouter = require 'vue-router'
App = require './App'

Vue.use VueRouter
Vue.use Vuex

store = new Vuex.Store
	state:
		count: 0
	mutations:
		increment: (state) ->
			state.count++

routes = [
	{ path: '/', component: App }
]

router = new VueRouter
	mode: 'history'
	routes: routes

app = new Vue
	router: router
.$mount '#app-mount'
