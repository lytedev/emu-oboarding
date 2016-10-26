MainStyles = require './styles/main.styl'

Vue = require 'vue'
Vuex = require 'vuex'
VueRouter = require 'vue-router'

Vue.use VueRouter
Vue.use Vuex

Intro = require './Intro.vue'
Loading = require './Loading.vue'
Offline = require './Offline.vue'
store = require '../store/index.coffee'

routes = [
	{ path: '/pin', component: Intro }
	{ path: '/offline', component: Intro }
	{ path: '/', component: Loading }
]

router = new VueRouter
	mode: 'history'
	routes: routes

app = new Vue
	router: router
	store: store
.$mount '#app-mount'

require './ws.coffee'
require './analytics.coffee'
