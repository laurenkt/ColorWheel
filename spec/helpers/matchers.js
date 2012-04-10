function isEqualRounded(x, y, decimalPlaces) {
	if (typeof x == 'undefined' && typeof y == 'undefined') return true;

	var factor = Math.pow(10, decimalPlaces);
	return Math.round(x*factor) === Math.round(y*factor);
}

function prettyRGB(rgb) {
	return "RGB(" +rgb.r+ ", " +rgb.b+ ", " +rgb.g+")"
}

function prettyHSL(hsl) {
	return "HSL(" +hsl.h+ ", " +hsl.s+ ", " +hsl.l+")"
}

beforeEach(function() {
	this.addMatchers({
		toEqualRGB: function(expected) {
			var actual = this.actual;

			this.message = function() {
				return "Expected " + prettyRGB(actual) + " to be " + prettyRGB(expected);
			}

			return isEqualRounded(expected.r, actual.r, 2) &&
			       isEqualRounded(expected.g, actual.g, 2) &&
			       isEqualRounded(expected.b, actual.b, 2);
		},
		toEqualHSL: function(expected) {
			var actual = this.actual;

			this.message = function() {
				return "Expected " + prettyHSL(actual) + " to be " + prettyHSL(expected);
			}

			return expected.h === actual.h &&
			       isEqualRounded(expected.s, actual.s, 2) &&
			       isEqualRounded(expected.l, actual.l, 2);
		}
	});
});
