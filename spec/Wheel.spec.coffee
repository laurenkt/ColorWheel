#= require jasmine-jquery

describe 'Wheel', ->
	# Save initialising over and over again
	colorWheel = null
	
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
			rgb: new cw.RGB(0, 1, 102/255)
			hsl: new cw.HSL(144)
			string: '#00ff66'
		partialSampleNoHue =
			rgb: new cw.RGB(0.5, 0.5, 0.5)
			hsl: new cw.HSL(undefined, 1, 0.5)
			string: '#808080'
		partialSampleSaturation =
			rgb: new cw.RGB(128/255, 128/255, 128/255)
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

		colorWheel = new cw.ColorWheel

	describe '.setHSL', ->
		it "should allow changing of HSL value", ->
			colorWheel.setHSL(normalSample1.hsl);
			
			expect( colorWheel.getHSL() ).toEqualHSL normalSample1.hsl

		it "should allow setting of default color", ->
			colorWheel = new cw.ColorWheel(defaultColor: normalSample1.hsl)
			
			expect( colorWheel.getHSL() ).toEqualHSL normalSample1.hsl

	describe '.canSetHue', ->
		it "should return true from the beginning in normal usage", ->
			expect( colorWheel.canSetHue() ).toBe true
		
		it "should return false from the beginning when option.allowHueSelection is false", ->
			colorWheel = new cw.ColorWheel(allowHueSelection: false)
			expect( colorWheel.canSetHue() ).toBe false
		
	describe '.canSetSL', ->
		it "should return false from the beginning in normal usage", ->
			expect( colorWheel.canSetSL() ).toBe false
		
		it "should return true from the beginning when option.allowPartialSelection is false", ->
			colorWheel = new cw.ColorWheel(allowPartialSelection: false)
			expect( colorWheel.canSetSL() ).toBe true
			
		it "should return true from the beginning when option.allowHueSelection is false", ->
			colorWheel = new cw.ColorWheel(allowHueSelection: false)
			expect( colorWheel.canSetSL() ).toBe true
			
		it "should always return false when option.allowSLSelection is false", ->
			colorWheel = new cw.ColorWheel(allowSLSelection: false)
			expect( colorWheel.canSetSL() ).toBe false
			colorWheel.setHSL(partialSampleHue.hsl)
			expect( colorWheel.canSetSL() ).toBe false
		
	describe '.isHueSelected', ->
		it "should return true if a complete color is set", ->
			colorWheel.setHSL(normalSample1.hsl)
			expect( colorWheel.isHueSelected() ).toBe true
			colorWheel.setHSL(normalSample2.hsl)
			expect( colorWheel.isHueSelected() ).toBe true
			colorWheel.setHSL(normalSample3.hsl)
			expect( colorWheel.isHueSelected() ).toBe true
			
		it "should return true if a partial color with hue is set", ->
			colorWheel.setHSL(partialSampleHue.hsl)
			expect( colorWheel.isHueSelected() ).toBe true
			colorWheel.setHSL(partialSampleNoSaturation.hsl)
			expect( colorWheel.isHueSelected() ).toBe true
			colorWheel.setHSL(partialSampleNoLightness.hsl)
			expect( colorWheel.isHueSelected() ).toBe true
			
		it "should return false if a partial color with no hue is set", ->
			colorWheel.setHSL(partialSampleNoHue.hsl)
			expect( colorWheel.isHueSelected() ).toBe false
			colorWheel.setHSL(partialSampleSaturation.hsl)
			expect( colorWheel.isHueSelected() ).toBe false
			colorWheel.setHSL(partialSampleLightness.hsl)
			expect( colorWheel.isHueSelected() ).toBe false
		
		it "should return false if a transparent color is set", ->
			colorWheel.setHSL(transparentSample.hsl)
			expect( colorWheel.isHueSelected() ).toBe false

		it "should return false if a complete color is set, and then a partial color with no hue is set", ->
			colorWheel.setHSL(normalSample1.hsl)
			colorWheel.setHSL(partialSampleNoHue.hsl)
			expect( colorWheel.isHueSelected() ).toBe false
			
		it "should return true if a partial color with no hue is set, and then a complete color is set", ->
			colorWheel.setHSL(partialSampleNoHue.hsl)
			colorWheel.setHSL(normalSample1.hsl)
			expect( colorWheel.isHueSelected() ).toBe true
		
	describe '.isSLSelected', ->

	describe 'option.defaultColor', ->
		
	describe 'option.inset', ->
	
	describe 'option.allowHueSelection', ->
	
	describe 'option.allowSLSelection', ->

	describe 'option.allowPartialSelection', ->
		describe '= true', ->
			beforeEach ->
				colorWheel = new cw.ColorWheel(allowPartialSelection: true);
	
			it "shouldn't allow S/L to be set until hue has been", ->
				expect( colorWheel.canSetSL() ).toBe false
	
				colorWheel.setHSL(partialSampleHue.hsl)
	
				expect( colorWheel.canSetSL() ).toBe true

		describe '= false', ->
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
			
	describe 'option.callback', ->
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
