import MainStyles from './styles/main.styl'

import Vue from 'vue'
import VueRouter from 'vue-router'
import App from './App'

Vue.use(VueRouter)

var routes = [
	{ path: '/', component: App }
]

var router = new VueRouter({
	mode: 'history',
	routes: routes
})

/* eslint-disable no-new */
var app = new Vue({
	router
}).$mount('#app-mount')
