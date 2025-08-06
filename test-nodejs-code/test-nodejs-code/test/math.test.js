const expect = require('chai').expect
const Math = require('../src/math')

describe('Math Tests', () => {

	let m

	before(()=>{
		m = new Math()
	})

	describe('Basic', () => {

		it('add', () => {
			expect(m.add(1, 1)).equals(2)
		})

		it('sub', () => {
			expect(m.sub(1, 1)).equals(0)
		})

		it('mult', () => {
			expect(m.mult(2, 2)).equals(4)
		})

		it('div', () => {
			expect(m.div(1, 1)).equals(1)
		})

		it('div by zero', () => {
			expect(m.div(1, 0)).to.be.NaN
		})

	})

	describe('Advanced', () => {

		it('square root', () => {
			expect(m.sqrt(4)).equals(2)
		})

		it('cubed root', () => {
			expect(m.cbrt(27)).equals(3)
		})

	})

})
