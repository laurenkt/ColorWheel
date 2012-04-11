#= require jasmine-jquery

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
			
	describe 'option:callback', ->
		callback = null
		
		mouseDownHue0 = null
		mouseDownHue180 = null

		beforeEach ->
			setFixtures('<div id="wheel"></div>')
			callback = jasmine.createSpy('callback')
			colorWheel = new cw.ColorWheel(callback:callback)
			$('#wheel').append colorWheel.$root
			
			mouseDownHue0 = $.Event 'mousedown', 
				pageX: colorWheel.$root.offset().left + colorWheel.$root.width()/2
				pageY: 0
			mouseDownHue180 = $.Event 'mousedown', 
				pageX: colorWheel.$root.offset().left + colorWheel.$root.width()/2
				pageY: colorWheel.$root.offset().top + colorWheel.$root.height()

		it "should allow a callback to be set", ->
			callback = ->
			colorWheel = new cw.ColorWheel(callback: callback)
			
			expect( colorWheel.options.callback ).toBe callback
		
		it "should invoke the callback when a new color is selected", ->
			colorWheel.$hue.trigger('mousedown')
			
			expect( callback ).toHaveBeenCalled()
		
		it "should invoke the callback with the colorwheel as its context", ->
			context = null
			colorWheel.options.callback = -> context = this

			colorWheel.$hue.trigger('mousedown')
			expect( context ).toBe colorWheel
		
		it "should invoke the callback with the selected color as its argument", ->
			watch = null			
			colorWheel.options.callback = (color) -> watch = color

			colorWheel.$hue.trigger(mouseDownHue0)
			expect( watch ).toEqualHSL new cw.HSL(0)
			colorWheel.$hue.trigger('mouseup')
		
			colorWheel.$hue.trigger(mouseDownHue180)
			expect( watch ).toEqualHSL new cw.HSL(180)
			colorWheel.$hue.trigger('mouseup')
			
			colorWheel.$sl.trigger $.Event 'mousedown', 
				pageX: colorWheel.$sl.offset().left + colorWheel.$sl.width()/4
				pageY: colorWheel.$sl.offset().top + colorWheel.$sl.height()/2
			expect( watch ).toEqualHSL new cw.HSL(180, 0.75, 0.5)
			colorWheel.$hue.trigger('mouseup')
		
		it "should allow a new color to be selected when the callback returns true", ->
			colorWheel.options.callback = -> true
			
			colorWheel.$hue.trigger(mouseDownHue0)
			expect( colorWheel.getHSL() ).toEqualHSL new cw.HSL(0)
			
		it "should not allow the color to be selected when the callback returns false", ->
			colorWheel.options.callback = -> false
			
			colorWheel.$hue.trigger(mouseDownHue0)
			expect( colorWheel.getHSL() ).not.toEqualHSL new cw.HSL(0)
			
		it "should allow a new color to be selected when the callback does not return a value", ->
			colorWheel.options.callback = ->
			
			colorWheel.$hue.trigger(mouseDownHue0)
			expect( colorWheel.getHSL() ).toEqualHSL new cw.HSL(0)
			
		it "should alter the selected color when the callback returns a different color", ->
			colorWheel.options.callback = -> normalSample1.hsl
				
			colorWheel.$hue.trigger(mouseDownHue0)
			expect( colorWheel.getHSL() ).toEqualHSL normalSample1.hsl
