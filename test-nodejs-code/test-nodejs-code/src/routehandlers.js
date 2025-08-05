/*
	This is the collection of route handlers that will be handled by express
*/

const Math = require('./math')
const math = new Math()

const getParams = request => {
	let a = Number(request.params.a),
		b = Number(request.params.b)
	return { a, b }
}

const hello = (request, response) => {
	response.end('Hello World!')
}

const add = (request, response) => {
	let { a, b } = getParams(request)
	response.send(math.add(a, b).toString())
}

const sub = (request, response) => {
	let { a, b } = getParams(request)
	response.send(math.sub(a, b).toString())
}

const mult = (request, response) => {
	let { a, b } = getParams(request)
	response.send(math.mult(a, b).toString())
}

const div = (request, response) => {
	let { a, b } = getParams(request)
	response.send(math.div(a, b).toString())
}

const sqrt = (request, response) => {
	response.send(math.sqrt(Number(request.params.a)).toString())
}

const cbrt = (request, response) => {
	response.send(math.cbrt(Number(request.params.a)).toString())
}

module.exports = [
	{ path: '/', handler: hello },
	{ path: '/add/:a/:b', handler: add },
	{ path: '/sub/:a/:b', handler: sub },
	{ path: '/mult/:a/:b', handler: mult },
	{ path: '/div/:a/:b', handler: div },
	{ path: '/sqrt/:a', handler: sqrt },
	{ path: '/cbrt/:a', handler: cbrt }
]
