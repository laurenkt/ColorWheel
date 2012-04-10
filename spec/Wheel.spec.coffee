describe 'Wheel', ->
	normalSample1 = null
	partialSampleHue = null
	colorWheel = null

	beforeEach ->
		normalSample1 =
			rgb: new cw.RGB(20/255, 184/255, 148/255)
			hsl: new cw.HSL(167, 0.8, 0.4)
			string: '#14b894'
		partialSampleHue =
			rgb: new cw.RGB(67/255, 1, 55/255)
			hsl: new cw.HSL(144)
			string: '#43ff37'

		colorWheel = new cw.ColorWheel

	describe '.setHSL', ->
		it "should allow changing of HSL value", ->
			colorWheel.setHSL(normalSample1.hsl);
			
			expect( colorWheel.getHSL() ).toEqualHSL normalSample1.hsl

		it "should allow setting of default color", ->
			colorWheel = new cw.ColorWheel(defaultColor: normalSample1.hsl)
			
			expect( colorWheel.getHSL() ).toEqualHSL normalSample1.hsl

	describe 'option:allowPartialSelection:true', ->
		beforeEach ->
			colorWheel = new cw.ColorWheel(allowPartialSelection: true);

		it "shouldn't allow S/L to be set until hue has been", ->
			expect( colorWheel.canSetSL() ).toBe false

			colorWheel.setHSL(partialSampleHue.hsl)

			expect( colorWheel.canSetSL() ).toBe true

	describe 'option:allowPartialSelection:false', ->
		beforeEach ->
			colorWheel = new cw.ColorWheel(allowPartialSelection: false)

		it "should allow all components to be set", ->
			expect( colorWheel.canSetSL() ).toBe true
			expect( colorWheel.canSetHue() ).toBe true

		it "should allow a complete component to be set", ->
			expect( (-> colorWheel.setHSL(normalSample1.hsl)) ).not.toThrow()
			expect( colorWheel.getHSL() ).toEqualHSL normalSample1.hsl

		it "shouldn't allow a partial component to be set", ->
			expect( (-> colorWheel.setHSL(partialSampleHue.hsl)) ).toThrow()