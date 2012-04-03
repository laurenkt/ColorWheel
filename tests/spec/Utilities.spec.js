describe("Utilities", function() {
	var aTransparentRGB = null;
	var anRGB = {r:0.5, g:0.6, b:0.4};
	var aHSL = {h:167, s:0.8, l:0.4};
	var aPartialHSL = {h:144};
	var someOtherObject = {some: 'Other'};
	var aColorString = '#3464AA';

	describe("isRGB", function() {
		it("should identify RGB objects as RGB", function() {
			expect(cw.isRGB(anRGB)).toBe(true);
			expect(cw.isRGB(aTransparentRGB)).toBe(true);
		});
		it("should not identify other objects as RGB", function() {
			expect(cw.isRGB(aHSL)).toBe(false);
			expect(cw.isRGB(someOtherObject)).toBe(false);
			expect(cw.isRGB(aColorString)).toBe(false);
		});
	});

	describe("isHSL", function() {
		it("should identify HSL objects as HSL", function() {
			expect(cw.isHSL(aHSL)).toBe(true);
			expect(cw.isHSL(aPartialHSL)).toBe(true);
			expect(cw.isHSL({})).toBe(true);
		});
		it("should not identify other objects as HSL", function() {
			expect(cw.isHSL(anRGB)).toBe(false);
			expect(cw.isHSL(someOtherObject)).toBe(false)
			expect(cw.isHSL(aColorString)).toBe(false);
		});
	});

	describe("isCompleteHSL", function() {
		it("should identify complete HSL objects as HSL", function() {
			expect(cw.isCompleteHSL(aHSL)).toBe(true);
		});
		it("should not identify partial HSL objects as HSL", function() {
			expect(cw.isCompleteHSL(aPartialHSL)).not.toBe(true);
			expect(cw.isCompleteHSL({})).not.toBe(true);
		});
	});

	describe("isColorString", function() {
		it("should identify color strings", function() {
			expect(cw.isColorString(aColorString)).toBe(true);
		});
		it("should consider 'transparent' a color string", function() {
			expect(cw.isColorString('transparent')).toBe(true);
		});
	});

	describe("RGB", function() {
		it("should construct RGB objects with all components", function() {
			expect(cw.RGB(0.5, 0.6, 0.4)).toEqual(anRGB);
		});

		it("should construct RGB objects without any components", function() {
			expect(cw.RGB()).toEqual(aTransparentRGB);
		});

		it("should construct RGB objects that can be identified by isRGB", function() {
			expect(cw.isRGB(cw.RGB(0.1, 0, 1))).toBe(true);
			expect(cw.isRGB(cw.RGB())).toBe(true);
		});
	});

	describe("RGBToString", function() {
		it("should convert RGB objects to CSS color strings", function() {
			var anRGB = {r:.078431373, g:.117647059, b:.745098039}; 
			var asColorString = '#141ebe';

			expect(cw.RGBToString(anRGB)).toBe(asColorString);
		});
		it("should convert null to CSS transparent", function() {
			expect(cw.RGBToString(null)).toBe('transparent');
		});
	});

	describe("HSLToRGB", function() {
		it("should convert whole HSL objects to RGB", function() {
			// using aHSL
			var asRGB = {r: .078431373, g: .721568627, b: .580392157};

			expect(cw.HSLToRGB(aHSL)).toEqualRGB(asRGB);
		});
		it("should convert empty HSL objects to RGB", function() {
			expect(cw.HSLToRGB({})).toBeNull();
		});
		it("should convert HSL objects with no hue to RGB", function() {
			var aHSL = {s:1, l:0.5};
			var asRGB = {r:0.5, g:0.5, b:0.5};

			expect(cw.HSLToRGB(aHSL)).toEqualRGB(asRGB);
		});
		it("should convert HSL objects with no saturation to RGB", function() {
			var aHSL = {h:0, l:0.5};
			var asRGB = {r:1, g:0, b:0};
			
			expect(cw.HSLToRGB(aHSL)).toEqualRGB(asRGB);
		});
		it("should convert HSL objects with no lightness to RGB", function() {
			var aHSL = {h:120, s:1};
			var asRGB = {r:0, g:1, b:0};

			expect(cw.HSLToRGB(aHSL)).toEqualRGB(asRGB);
		});
	});

	describe("stringToRGB", function() {
		it("should convert CSS color strings to RGB", function() {
			// using aColorString
			var asRGB = {r:.203921569, g:.392156863, b:.666666667};

			expect(cw.stringToRGB(aColorString)).toEqualRGB(asRGB);
		});
		it("should convert 'transparent' to RGB", function() {
			expect(cw.stringToRGB('transparent')).toBeNull();
		});
	});

	describe("colorToRGB", function() {
		it("should return RGB objects unchanged", function() {
			expect(cw.colorToRGB(anRGB)).toEqual(anRGB);
		});
		it("should coerce HSL objects to RGB", function() {
			// using aHSL
			var asRGB = {r: .078431373, g: .721568627, b: .580392157};

			expect(cw.colorToRGB(aHSL)).toEqualRGB(asRGB);
		});
		it("should coerce CSS color strings to RGB", function() {
			// using aColorString
			var asRGB = {r:.203921569, g:.392156863, b:.666666667};

			expect(cw.colorToRGB(aColorString)).toEqualRGB(asRGB);
		});
	});

});
