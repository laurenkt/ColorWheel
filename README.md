ColorWheel
==========

**Warning**: this isn't ready for primetime yet - some features aren't fully implemented, and test coverage is incomplete.

A hue/saturation/lightness color wheel for jQuery.

_Note_: I do accept pull requests (so long as they are reasonable, and do not cause any tests to fail)

Features
--------

(Get a look at the demos to see what these actually mean)

- Partial selection
- Interface hinting
- Track changes with callbacks or events
- Validate and allow/reject changes in real-time with callbacks
- Change the size of the interface elements (look in the graphics/ folder for a README on how to make your own sprites)
- Provides utilities for conversion between HSL, RGB, and CSS color strings

Installation
------------

See the demo/ folder for an example, or:

1. 	Ensure your page has a script element for jQuery. (If you want the interface hinting for the S/L box, you also need [a jQuery plug-in to enable animating the box-shadow property](http://www.bitstorm.org/jquery/shadow-animation/) as jQuery core does not currently support this.)

2. 	You need the `cw-colorwheel.js`, `cw-style.css`, and `cw-sprites.png`, include the first two in your page like so:
	
		<link rel="stylesheet" href="cw-style.css" type="text/css">
		<script type="text/javascript" src="cw-colorwheel.js"></script>
	
	Preferably in your `<head>` element, but definitely after jQuery.

3. 	Use the jQuery plug-in to append a color wheel to an element:
	
		$('#someElement').colorWheel();
	
	Access this created color wheel using the data attribute created for ColorWheel:
	
		$('#someElement').data('colorWheel.cw').setHSL(cw.HSL(120, 1, 0.5)); // sets the colorWheel to green
	
	Alternatively, create a color wheel yourself. You can access its root node with `colorWheel.getRoot()`
	
		colorWheel = new cw.ColorWheel;
		colorWheel.setHSL(cw.HSL(240, 1, 0.5)); // sets the colorWheel to blue
		$('#someElement').append(colorWheel.getRoot());

Optionally, both methods allow specifying an object with initial parameters for the color wheel:

	options = {
		callback: null, // a callback function
		defaultColor: cw.HSL(), // the starting color for the wheel
		inset: 10, // the amount the hue marker is inset from the edge of the wheel
		allowPartialSelection: true, // whether the color wheel can have a hue set without an s/l set
		pingEnable: false // whether the color wheel should hint the user to select an s/l when a hue is set (requires jQuery box-shadow animation plug-in)
	}
	
	// then:
	
	new cw.ColorWheel(options)
	
	// or:
	
	$('#someElement').colorWheel(options);

Utilities
---------

Several utility functions are provided for those working with colors:

- `cw.RGB(r, g, b)` creates an RGB object
- `cw.HSL(h, s, l)` creates an HSL object
- `cw.isRGB(c)` returns `true` iff `c` is an RGB object
- `cw.isHSL(c)` returns `true` iff `c` is an HSL object
- `cw.isColorString(c)` returns `true` iff `c` is a CSS color string
- `cw.RGBToHSL(rgb)` converts an RGB object to an HSL object
- `cw.RGBToString(rgb)` converts an RGB object to a CSS color string
- `cw.HSLToRGB(hsl)` converts an HSL object to an RGB object
- `cw.HSLToString(hsl)` converts an HSL object to a CSS color string
- `cw.stringToRGB(string)` converts a CSS color string to an RGB object
- `cw.stringToHSL(string)` converts a CSS color string to an HSL object
- `cw.colorToRGB(c)` converts an RGB/HSL object or a CSS color string to an RGB object
- `cw.colorToHSL(c)` converts an RGB/HSL object or a CSS color string to an HSL object
- `cw.colorToString(c)` converts an RGB/HSL object or a CSS color string to a CSS color string

Licence
-------

Use what you want, how you want, with or without attribution, with no guarantee that it will work.
