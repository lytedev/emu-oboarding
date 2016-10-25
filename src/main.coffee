MainStyles = require './styles/main.styl'

Vue = require 'vue'
Vuex = require 'vuex'
VueRouter = require 'vue-router'

Vue.use VueRouter
Vue.use Vuex

App = require './App.vue'
store = require '../store/index.coffee'


routes = [
	{ path: '/', component: App }
]

router = new VueRouter
	mode: 'history'
	routes: routes

app = new Vue
	router: router
	store: store
.$mount '#app-mount'

console.log store
