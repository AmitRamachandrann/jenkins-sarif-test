const expect = require('chai').expect
const request = require('request')

describe('Integration Tests', () => {
	
	it('hello world', () => {
		request('http://localhost:8080/', function (error, response, body) {
			expect(response && response.statusCode).to.equal(200)
			expect(body).to.equal('Hello World!')
			expect(error).to.equal(null)
		})
	})

	it('adds', () => {
		request('http://localhost:8080/add/3/2', function (error, response, body) {
			expect(response && response.statusCode).to.equal(200)
			expect(body).to.equal('5')
			expect(error).to.equal(null)
		})
	})

	it('subtracts', () => {
		request('http://localhost:8080/sub/3/2', function (error, response, body) {
			expect(response && response.statusCode).to.equal(200)
			expect(body).to.equal('1')
			expect(error).to.equal(null)
		})
	})

	it('multiplies', () => {
		request('http://localhost:8080/mult/3/2', function (error, response, body) {
			expect(response && response.statusCode).to.equal(200)
			expect(body).to.equal('6')
			expect(error).to.equal(null)
		})
	})

	it('divides', () => {
		request('http://localhost:8080/div/3/2', function (error, response, body) {
			expect(response && response.statusCode).to.equal(200)
			expect(body).to.equal('1.5')
			expect(error).to.equal(null)
		})
	})

	it('roots', () => {
		request('http://localhost:8080/sqrt/4', function (error, response, body) {
			expect(response && response.statusCode).to.equal(200)
			expect(body).to.equal('2')
			expect(error).to.equal(null)
		})
	})

	it('cubed roots', () => {
		request('http://localhost:8080/cbrt/27', function (error, response, body) {
			expect(response && response.statusCode).to.equal(200)
			expect(body).to.equal('3')
			expect(error).to.equal(null)
		})
	})

	it('404 error', () => {
		request('http://localhost:8080/binroot', function (error, response) {
			expect(response && response.statusCode).to.equal(404)
			expect(error).to.equal(null)
		})
	})

})
