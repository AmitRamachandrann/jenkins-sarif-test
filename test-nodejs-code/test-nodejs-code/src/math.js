const { sqrt, cbrt } = require('mathjs')

module.exports = class Math {

	constructor() {
	}

	add(a, b) {
		return a + b
	}

	sub(a, b) {
		return a - b
	}

	mult(a, b) {
		return a * b
	}

	div(a, b) {
		if (b === 0) {
			return NaN
		}
		return a / b
	}

	sqrt(a) {
		return sqrt(a)
	}

	cbrt(a) {
		return cbrt(a)
	}
}
