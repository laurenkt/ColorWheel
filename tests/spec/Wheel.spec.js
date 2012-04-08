describe("Wheel", function() {
	var aHSL;
	var colorWheel;

	beforeEach(function() {
		aHSL = new cw.HSL(167, 0.8, 0.4);
	});

	describe(".setHSL", function() {
		it("should allow changing of HSL value", function() {
			colorWheel = new cw.ColorWheel;
			colorWheel.setHSL(aHSL);
			
			expect(colorWheel.getHSL()).toEqualHSL(aHSL);
		});
		it("should allow setting of default color", function() {
			colorWheel = new cw.ColorWheel({defaultColor:aHSL});

			expect(colorWheel.getHSL()).toEqualHSL(aHSL);
		});
	});

	describe("option:allowPartialSelection:true", function() {
		beforeEach(function() {
			colorWheel = new cw.ColorWheel({allowPartialSelection:true});
		});

		it("shouldn't allow S/L to be set until hue has been", function() {
			expect(colorWheel.canSetSL()).toBe(false);

			colorWheel.setHSL(new cw.HSL(0));
			expect(colorWheel.canSetSL()).toBe(true);
		});
	});

	describe("option:allowPartialSelection:false", function() {
		beforeEach(function() {
			colorWheel = new cw.ColorWheel({allowPartialSelection:false});
		});

		it("should allow all components to be set", function() {
			expect(colorWheel.canSetSL()).toBe(true);
			expect(colorWheel.canSetHue()).toBe(true);
		});

		it("should allow a complete component to be set", function() {
			expect(function(){colorWheel.setHSL(new cw.HSL(126, 0.4, 0.6))}).not.toThrow();
			expect(colorWheel.getHSL()).toEqualHSL(new cw.HSL(126, 0.4, 0.6));
		});

		it("shouldn't allow a partial component to be set", function() {
			expect(function(){colorWheel.setHSL({h:0})}).toThrow();
		});
	});
});
