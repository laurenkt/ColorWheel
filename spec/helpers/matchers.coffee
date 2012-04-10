eqRounded = (x, y, delta = 1/255) ->
	if isNaN(x)
		isNaN(y)
	else
		(x - delta) <= y <= (x + delta)

eqRoundedRGB = (a, b) ->
	eqRounded(a.r, b.r) and eqRounded(a.g, b.g) and eqRounded(a.b, b.b)

eqRoundedHSL = (a, b) ->
	eqRounded(a.h, b.h, 360/255) and eqRounded(a.s, b.s) and eqRounded(a.l, b.l)

prettyRGB = (rgb) ->
	"RGB(#{rgb.r}, #{rgb.b}, #{rgb.g})"

prettyHSL = (hsl) ->
	"HSL(#{hsl.h}, #{hsl.s}, #{hsl.l})"

beforeEach ->
	this.addMatchers
		toEqualRGB: (expected) ->
			this.message = =>
				"Expected #{prettyRGB(this.actual)} to be #{prettyRGB(expected)}"

			eqRoundedRGB(expected, this.actual)

		toEqualHSL: (expected) ->
			this.message = =>
				"Expected #{prettyHSL(this.actual)} to be #{prettyHSL(expected)}"

			eqRoundedHSL(expected, this.actual)