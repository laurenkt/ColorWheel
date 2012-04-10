describe 'Color', ->
	# Samples
	normalSample1 = null
	normalSample2 = null
	normalSample3 = null
	transparentSample = null
	partialSampleHue = null
	partialSampleSaturation = null
	partialSampleLightness = null
	partialSampleNoHue = null
	partialSampleNoSaturation = null
	partialSampleNoLightness = null

	beforeEach ->
		normalSample1 =
			rgb: new cw.RGB(20/255, 184/255, 148/255)
			hsl: new cw.HSL(167, 0.8, 0.4)
			string: '#14b894'
		normalSample2 =
			rgb: new cw.RGB(0.4, 0.6, 0.4)
			hsl: new cw.HSL(120, 0.2, 0.5)
			string: '#669966'
		normalSample3 =
			rgb: new cw.RGB(53/255, 100/255, 172/255)
			hsl: new cw.HSL(216, 0.53, 0.44)
			string: '#3564ac'
		transparentSample =
			rgb: new cw.RGB()
			hsl: new cw.HSL()
			string: 'transparent'
		partialSampleHue =
			rgb: new cw.RGB(67/255, 1, 55/255)
			hsl: new cw.HSL(144)
			string: '#43ff37'
		partialSampleNoHue =
			rgb: new cw.RGB(0.5, 0.5, 0.5)
			hsl: new cw.HSL(undefined, 1, 0.5)
			string: '#808080'
		partialSampleSaturation =
			rgb: new cw.RGB(0.5, 0.5, 0.5)
			hsl: new cw.HSL(undefined, 0.32)
			string: '#808080'
		partialSampleNoSaturation =
			rgb: new cw.RGB(1, 0, 0)
			hsl: new cw.HSL(0, undefined, 0.5)
			string: '#ff0000'
		partialSampleLightness =
			rgb: new cw.RGB(242/255, 242/255, 242/255)
			hsl: new cw.HSL(undefined, undefined, 0.95)
			string: '#f2f2f2'
		partialSampleNoLightness =
			rgb: new cw.RGB(0, 1, 0)
			hsl: new cw.HSL(120, 1)
			string: '#00ff00'

	describe 'HSL', ->
		describe '.isPartial', ->
			it "should return true for partial HSL objects", ->
				expect( transparentSample.hsl.isPartial() ).toBe true
				
				expect( partialSampleHue.hsl.isPartial() ).toBe true
				expect( partialSampleSaturation.hsl.isPartial() ).toBe true
				expect( partialSampleLightness.hsl.isPartial() ).toBe true
				
				expect( partialSampleNoHue.hsl.isPartial() ).toBe true
				expect( partialSampleNoSaturation.hsl.isPartial() ).toBe true
				expect( partialSampleNoLightness.hsl.isPartial() ).toBe true

			it "should return false for complete HSL objects", ->
				expect( normalSample1.hsl.isPartial() ).not.toBe true
				expect( normalSample2.hsl.isPartial() ).not.toBe true
				expect( normalSample3.hsl.isPartial() ).not.toBe true

		describe '.toRGB', ->
			it "should convert complete HSL objects to RGB", ->
				expect( normalSample1.hsl.toRGB() ).toEqualRGB normalSample1.rgb
				expect( normalSample2.hsl.toRGB() ).toEqualRGB normalSample2.rgb
				expect( normalSample3.hsl.toRGB() ).toEqualRGB normalSample3.rgb

			it "should convert transparent HSL objects to RGB", ->
				expect( transparentSample.hsl.toRGB() ).toEqualRGB transparentSample.rgb

			it "should convert HSL objects with no hue to RGB", ->
				expect( partialSampleNoHue.hsl.toRGB() ).toEqualRGB partialSampleNoHue.rgb

			it "should convert HSL objects with no saturation to RGB", ->
				expect( partialSampleNoSaturation.hsl.toRGB() ).toEqualRGB partialSampleNoSaturation.rgb

			it "should convert HSL objects with no lightness to RGB", ->
				expect( partialSampleNoLightness.hsl.toRGB() ).toEqualRGB partialSampleNoLightness.rgb

	describe 'RGB', ->
		describe '.toHSL', ->
			it "should convert RGB objects to HSL", ->
				expect( normalSample1.rgb.toHSL() ).toEqualHSL normalSample1.hsl
				expect( normalSample2.rgb.toHSL() ).toEqualHSL normalSample2.hsl
				expect( normalSample3.rgb.toHSL() ).toEqualHSL normalSample3.hsl

			it "should convert transparent RGB objects to transparent HSL objects", ->
				expect( transparentSample.rgb.toHSL() ).toEqualHSL transparentSample.hsl

		describe '.toString', ->
			it "should convert RGB objects to CSS color strings", ->
				expect( normalSample1.rgb.toString() ).toBe normalSample1.string
				expect( normalSample2.rgb.toString() ).toBe normalSample2.string
				expect( normalSample3.rgb.toString() ).toBe normalSample3.string

			it "should convert transparent RGB objects to CSS transparent", ->
				expect( transparentSample.rgb.toString() ).toBe transparentSample.string

		describe '::fromString', ->
			it "should convert CSS color strings to RGB", ->
				expect( cw.RGB.fromString(normalSample1.string) ).toEqualRGB normalSample1.rgb
				expect( cw.RGB.fromString(normalSample2.string) ).toEqualRGB normalSample2.rgb
				expect( cw.RGB.fromString(normalSample3.string) ).toEqualRGB normalSample3.rgb

			it "should convert 'transparent' to RGB", ->
				expect( cw.RGB.fromString(transparentSample.string) ).toEqualRGB transparentSample.rgb