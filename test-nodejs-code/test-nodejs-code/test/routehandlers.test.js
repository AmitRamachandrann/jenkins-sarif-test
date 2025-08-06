const httpMocks = require('node-mocks-http')
const routehandlers = require('../src/routehandlers')
const expect = require('chai').expect

describe('Route Handlers', () => {

	let rhmap = {}

	before(() => {
		for (let i = 0; i < routehandlers.length; ++i) {
			rhmap[routehandlers[i].path] = routehandlers[i].handler
		}
	})

	describe('Basic', () => {

		it('tests hello handler', () => {
			let request = httpMocks.createRequest({ method: 'GET', url: '/' }),
				response = httpMocks.createResponse()

			rhmap['/'](request, response)
			expect(response._getData()).equals('Hello World!')
		})

		it('tests add handler', () => {
			let request = httpMocks.createRequest({ method: 'GET', url: '/add/3/2', params: { a: '3', b: '2' } }),
				response = httpMocks.createResponse()

			rhmap['/add/:a/:b'](request, response)
			expect(response._getData()).equals('5')
		})

		it('tests subtraction handler', () => {
			let request = httpMocks.createRequest({ method: 'GET', url: '/sub/3/2', params: { a: '3', b: '2' } }),
				response = httpMocks.createResponse()

			rhmap['/sub/:a/:b'](request, response)
			expect(response._getData()).equals('1')
		})

		it('tests multiplication handler', () => {
			let request = httpMocks.createRequest({ method: 'GET', url: '/mult/3/2', params: { a: '3', b: '2' } }),
				response = httpMocks.createResponse()

			rhmap['/mult/:a/:b'](request, response)
			expect(response._getData()).equals('6')
		})

		it('tests division handler', () => {
			let request = httpMocks.createRequest({ method: 'GET', url: '/div/3/2', params: { a: '3', b: '2' } }),
				response = httpMocks.createResponse()

			rhmap['/div/:a/:b'](request, response)
			expect(response._getData()).equals('1.5')
		})

	})

	describe('Advanced', () => {

		it ('tests square root', () => {
			let request = httpMocks.createRequest({ method: 'GET', url: '/sqrt/4', params: { a: '4' }}),
				response = httpMocks.createResponse()

			rhmap['/sqrt/:a'](request, response)
			expect(response._getData()).equals('2')
		})

		it ('tests cubed root', () => {
			let request = httpMocks.createRequest({ method: 'GET', url: '/cbrt/27', params: { a: '27' }}),
				response = httpMocks.createResponse()

			rhmap['/cbrt/:a'](request, response)
			expect(response._getData()).equals('3')
		})
		
	})

})