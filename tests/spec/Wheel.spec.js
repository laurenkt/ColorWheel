describe("ColorWheel", function() {
	var aHSL = {h:167, s:0.8, l:0.4};

	describe(".setHSL", function() {
		it("should allow changing of HSL value", function() {
			var colorWheel = new cw.ColorWheel;
			colorWheel.setHSL(aHSL);
			
			expect(colorWheel.getHSL()).toEqualHSL(aHSL);
		});
		it("should allow setting of default color", function() {
			var colorWheel = new cw.ColorWheel({defaultColor:aHSL});

			expect(colorWheel.getHSL()).toEqualHSL(aHSL);
		});
	});
});
