const config = require('config')
const express = require('express')

const port = config.application.port
const app = express()
const routehandlers = require('./routehandlers')

app.listen(port)

console.log(`server started listening on ${port}`)

routehandlers.forEach(rh => {
	app.get(rh.path, rh.handler)
})
