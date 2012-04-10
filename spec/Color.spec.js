describe("Color", function() {
	var aTransparentRGB;
	var anRGB;
	var aHSL;
	var aPartialHSL;
	var anEmptyHSL; 
	var someOtherObject = {some: 'Other'};
	var aColorString = '#3464AA';

	beforeEach(function() {
		aTransparentRGB = new cw.RGB();
		anRGB = new cw.RGB(0.4, 0.6, 0.4);
		aHSL = new cw.HSL(167, 0.8, 0.4);
		aPartialHSL = new cw.HSL(144);
		anEmptyHSL = new cw.HSL();
	});

	describe("HSL", function() {
		describe(".isPartial", function() {
			it("should return true for partial HSL objects ", function() {
				expect(anEmptyHSL.isPartial()).toBe(true);
				expect(aPartialHSL.isPartial()).toBe(true);
			});
			it("should return false for complete HSL objects", function() {
				expect(aHSL.isPartial()).not.toBe(true);
			});
		});

		describe(".toRGB", function() {
			it("should convert complete HSL objects to RGB", function() {
				// using aHSL
				var asRGB = new cw.RGB(.078431373, .721568627, .580392157);

				expect(aHSL.toRGB()).toEqualRGB(asRGB);
			});
			it("should convert empty HSL objects to RGB", function() {
				expect(anEmptyHSL.toRGB()).toEqualRGB(new cw.RGB());
			});
			it("should convert HSL objects with no hue to RGB", function() {
				var aHSL = new cw.HSL(); aHSL.s = 1; aHSL.l = 0.5;
				var asRGB = new cw.RGB(0.5, 0.5, 0.5);

				expect(aHSL.toRGB()).toEqualRGB(asRGB);
			});
			it("should convert HSL objects with no saturation to RGB", function() {
				var aHSL = new cw.HSL(); aHSL.h = 0; aHSL.l = 0.5;
				var asRGB = new cw.RGB(1, 0, 0);
				
				expect(aHSL.toRGB()).toEqualRGB(asRGB);
			});
			it("should convert HSL objects with no lightness to RGB", function() {
				var aHSL = new cw.HSL(120, 1);
				var asRGB = new cw.RGB(0, 1, 0);

				expect(aHSL.toRGB()).toEqualRGB(asRGB);
			});
		});		
	});

	describe("RGB", function() {
		describe(".toHSL", function() {
			it("should convert RGB objects to HSL", function() {
				var anRGB = new cw.RGB(1, 0, 0);
				var asHSL = new cw.HSL(0, 1, 0.5);

				expect(anRGB.toHSL()).toEqualHSL(asHSL);
			});
			it("should convert transparent RGB objects to empty HSL objects", function() {
				expect((new cw.RGB()).toHSL()).toEqualHSL(new cw.HSL());
			});
		});

		describe(".toString", function() {
			it("should convert RGB objects to CSS color strings", function() {
				var anRGB = new cw.RGB(.078431373, .117647059, .745098039); 
				var asColorString = '#141ebe';

				expect(anRGB.toString()).toBe(asColorString);
			});
			it("should convert null to CSS transparent", function() {
				var anRGB = new cw.RGB();
				expect(anRGB.toString()).toBe('transparent');
			});
		});

		describe("::fromString", function() {
			it("should convert CSS color strings to RGB", function() {
				// using aColorString
				var asRGB = new cw.RGB(.203921569, .392156863, .666666667);

				expect(cw.RGB.fromString(aColorString)).toEqualRGB(asRGB);
			});
			it("should convert 'transparent' to RGB", function() {
				expect(cw.RGB.fromString('transparent')).toEqualRGB(new cw.RGB());
			});
		});
	});
});
