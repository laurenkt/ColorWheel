function isEqualRounded(x, y, decimalPlaces) {
	var factor = Math.pow(10, decimalPlaces);
	return Math.round(x*factor) === Math.round(y*factor);
}

beforeEach(function() {
	this.addMatchers({
		toEqualRGB: function(expected) {
			return isEqualRounded(expected.r, this.actual.r, 2) &&
			       isEqualRounded(expected.g, this.actual.g, 2) &&
			       isEqualRounded(expected.b, this.actual.b, 2);
		},
		toEqualHSL: function(expected) {
			return expected.h === this.actual.h &&
			       isEqualRounded(expected.s, this.actual.s, 2) &&
			       isEqualRounded(expected.l, this.actual.l, 2);
		}
	});
});
