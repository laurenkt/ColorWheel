ColorWheel
==========

**Warning**: this isn't ready for primetime yet - some features aren't fully implemented, and test coverage is incomplete.

A JavaScript **hue/saturation/lightness color wheel** for jQuery written in CoffeeScript.

_Note: I do accept pull requests (so long as they are reasonable, maintain coding style, and do not cause any tests to fail - run `rake && rake test` before submitting a pull request)_

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

As ColorWheel is still 'alpha' software, there are currently no releases. To use it you must build CW yourself (requires [CoffeeScript](http://coffeescript.org/) and [Rake](http://rake.rubyforge.org/)).

	git clone git://github.com/Comaleaf/ColorWheel.git
	cd ColorWheel
	rake

Use `rake minify` for minified output (requires [Google Closure Compiler](https://developers.google.com/closure/compiler/)).

Usage
-----

See the demo/ folder for usage examples, or:

**Include jQuery on your page**. (If you want the interface hinting for the S/L box, you also need [a jQuery plug-in to enable animating the box-shadow property](http://www.bitstorm.org/jquery/shadow-animation/) as jQuery core does not currently support this.)

**You need `cw-colorwheel.js`, `cw-style.css`, and `cw-sprites.png`**. **Include the first two in your page** like so:

```html	
<link rel="stylesheet" href="cw-style.css" type="text/css">
<script type="text/javascript" src="cw-colorwheel.js"></script>
```

Preferably in your `<head>` element, but definitely after jQuery.

**Use CW as a jQuery plug-in** to append a color wheel to an element:

```javascript
$('#someElement').colorWheel();
```

Access this created color wheel using the `data` attribute created for ColorWheel:

```javascript
$('#someElement').data('colorWheel.cw').setHSL(new cw.HSL(120, 1, 0.5)); // sets the colorWheel to green
```

Alternatively, create a color wheel yourself. You can access its root DOM node with `colorWheel.$root`

```javascript
colorWheel = new cw.ColorWheel;
colorWheel.setHSL(new cw.HSL(240, 1, 0.5)); // sets the colorWheel to blue
$('#someElement').append(colorWheel.$root);
```

To track changes you can either use the callback option (particularly if you want to allow/reject/alter the changes as they are made), or use the `change` event:

```javascript
// example binds event for to all color wheels
$(':color-wheel').bind('change', function(e, colorWheel) {
	$('body').css('background-color', colorWheel.getHSL());
});
```

Specify an object with initial parameters for the color wheel:

```javascript
options = {
	callback: null,              // a callback function
	defaultColor: new cw.HSL(),  // the starting color for the wheel
	inset: 10,                   // the amount the hue marker is inset from the edge of the wheel
	allowPartialSelection: true, // whether the color wheel can have a hue set without an s/l set
	hintEnable: false            // whether the color wheel should hint the user to select an s/l
	                             // when a hue is set (requires jQuery box-shadow animation plug-in)
}

// then either:
new cw.ColorWheel(options) // or:
$('#someElement').colorWheel(options);
```

If you do not want ColorWheel to use the global name 'cw', you can return that name to its original owner and use a new reference with the `noConflict` method:

```javascript
CWLib = cw.noConflict()
// 'cw' now refers to what it did before CW was included,
// 'CWLib' can be used instead from this point
```

If you have used jQuery's noConflict feature to rescind its control of the 'jQuery' identifier before you include jQuery, you can set CW to use a different jQuery identifier:

```javascript
cw.jQuery(jQ) // where you are using jQ instead of 'jQuery'
```

Utilities
---------

Several color utility objects are provided (and used internally):

- `new cw.RGB(r, g, b)` creates an RGB object
- `new cw.HSL(h, s, l)` creates an RGB object

Both of these implement the following methods:

- `.toString()` to convert to CSS hex color representation (#aabbcc)
- `.toHSL()` to create a new HSL object from this color
- `.toRGB()` to create a new RGB object from this color
- `.isTransparent()` determines if this object is considered fully transparent

The HSL object also implements:

- `.isPartial()` determines if this object is a 'partial' HSL object (i.e. missing one or more of its hue, saturation, or lightness components).

You can also initialise either of these objects with a CSS hex string using:

- `cw.RGB.fromString(string)` and
- `cw.HSL.fromString(string)` where string may be in the form '#aabbcc' or '#abc' or 'transparent'. 

Licence
-------

Use what you want, how you want, with or without attribution, with no guarantee that it will work.
