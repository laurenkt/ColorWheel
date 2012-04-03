cw = (function($) {
	// define inner identifier so internal references to cw.* still work if outer identifier is altered
	var cw = {
		/*
		 * Constructors 
		 */

		RGB: function(r, g, b) {
			if (arguments.length == 0) return null;
			return {r:r, g:g, b:b};
		},

		HSL: function(h, s, l) {
			if (arguments.length == 0) return {};
			return {h:h, s:s, l:l};
		},

		/*
		 * Type Identifiers
		 */

		isRGB: function(rgb) {
			return rgb == null ||
			       ($.isPlainObject(rgb) && 'r' in rgb && 'g' in rgb && 'b' in rgb);
		},

		isHSL: function(hsl) {
			return $.isPlainObject(hsl) &&
			       ($.isEmptyObject(hsl) || 'h' in hsl || 's' in hsl || 'l' in hsl);
		},

		isCompleteHSL: function(hsl) {
			return $.isPlainObject(hsl) &&
			       ('h' in hsl && 's' in hsl && 'l' in hsl);
		},

		isColorString: function(str) {
			return typeof str == 'string' && 
			       (str == 'transparent' ||
			       (str[0] == '#' && (str.length == 4 || str.length == 7)));
		},

		/*
		 * Type Coercion
		 */

		colorToRGB: function(color) {
			if (cw.isRGB(color)) return color;
			if (cw.isHSL(color)) return cw.HSLToRGB(color);
			if (cw.isColorString(color)) return cw.stringToRGB(color);
		},

		colorToHSL: function(color) {
			if (cw.isHSL(color)) return color;
			if (cw.isRGB(color)) return cw.RGBToHSL(color);
			if (cw.isColorString(color)) return cw.stringToHSL(color);
		},

		colorToString: function(color) {
			if (cw.isColorString(color)) return color;
			if (cw.isHSL(color)) return cw.HSLToString(color);
			if (cw.isRGB(color)) return cw.RGBToString(color);
		},

		HSLToRGB: function(hsl) {
			if ($.isEmptyObject(hsl)) return null;

			// sensible defaults for partial hsl value
			hsl = $.extend({s:1, l:0.5}, hsl);
			var h = hsl.h, s = hsl.s, l = hsl.l;

			h /= 60; // convert from circlular to hexagonal representation, h represents side

			var chroma = (1 - Math.abs(2*l - 1)) * s;
			var min = l - chroma/2; // find smallest component
			var mid = chroma * (1 - Math.abs(h%2 - 1)); // find middle component
			
			// returns RGB value equally lightened by smallest component
			function f(r, g, b) {
				return cw.RGB(r+min, g+min, b+min);
			}

			return (0 <= h && h < 1) ? f(chroma, mid, 0) :
			       (1 <= h && h < 2) ? f(mid, chroma, 0) :
			       (2 <= h && h < 3) ? f(0, chroma, mid) :
			       (3 <= h && h < 4) ? f(0, mid, chroma) :
			       (4 <= h && h < 5) ? f(mid, 0, chroma) :
			       (5 <= h && h < 6) ? f(chroma, 0, mid) :
			       f(l, l, l); // default
		},

		RGBToHSL: function(rgb) {
			if (rgb == null) return {};

			var h, s, l;
			var r = rgb.r, g = rgb.g, b = rgb.b;

			var max = Math.max(r, g, b);
			var min = Math.min(r, g, b);
			var chroma = max - min;
			
			l = (max + min)/2; // average of largest and smallest components

			if (chroma == 0) return {s:0, l:l}; // achromatic

			     if (max == r) h = (g - b)/chroma % 6;
			else if (max == g) h = (b - r)/chroma + 2;
			else if (max == b) h = (r - g)/chroma + 4;

			h *= 60; // convert from hexagonal representaiton to circular
			s = chroma/(1 - Math.abs(2*l - 1));

			return cw.HSL(h, s, l);
		},

		RGBToString: function(rgb) {
			if (rgb == null) return 'transparent';

			function decToHexByte(decByte) {
				if (decByte < 16) {
					return '0' + Math.round(decByte).toString(16);
				}

				return Math.round(decByte).toString(16);
			};

			return '#' + decToHexByte(rgb.r * 255) +
			             decToHexByte(rgb.g * 255) +
			             decToHexByte(rgb.b * 255);
		},

		HSLToString: function(hsl) { return cw.RGBToString(cw.HSLToRGB(hsl)); },

		stringToRGB: function(string) {
			if (string == 'transparent') return null;
			
			var extract = function(part) { return parseInt(string.substring(part*2 + 1, part*2 + 3), 16) / 255; };

			// use a different extract if form is #abc
			if (string.length == 4) {
				extract = function(part) { return parseInt(string[part+1], 16) / 15; }
			}
			
			return cw.RGB(extract(0), extract(1), extract(2));
		},

		stringToHSL: function(string) { return cw.RGBToHSL(cw.stringToRGB(string)); },

		/*
		 * Color wheel functionality implemented in ColorWheel object
		 */
		ColorWheel: function(options) {
			options = $.extend({
				callback: null,
				defaultColor: cw.HSL(),
				inset: 10,
				allowPartialSelection: true,
				allowHueSelection: true,
				allowSLSelection: true,
				animationTime: 200,
				pingEnable: false,
				pingQueue: 'ping.cw',
				pingTime: 500
			}, options);

			/*
			 * Private variables
			 */

			var _hsl = cw.colorToHSL(options.defaultColor);
			var _callback = options.callback;
			var _nodes = {};
			var _selected = 'none';

			/*
			 * Private functions
			 */

			function _coordsRelativeToCenter(x, y) {
				var offset = _nodes.$root.offset();
				return {x: (x - offset.left) - _nodes.$root.width()/2,
				        y: (y - offset.top) - _nodes.$root.height()/2};
			};

			function _markerCoordsForHue(hue) {
				var wheelRadius = _nodes.$hueInput.width() / 2;
				var markerRailRadius = wheelRadius - options.inset;

				hue *= Math.PI/180; // convert to radians

				var x = Math.sin(hue) * markerRailRadius + wheelRadius;
				var y = -Math.cos(hue) * markerRailRadius + wheelRadius;

				return {x:Math.round(x), y:Math.round(y)};
			}

			function _markerCoordsForSL(saturation, lightness) {
				var x = _nodes.$slInput.width() * (0.5 - saturation) + _nodes.$root.width()/2;
				var y = _nodes.$slInput.height() * (0.5 - lightness) + _nodes.$root.height()/2;

				return {x:Math.round(x), y:Math.round(y)};
			}

			function _ping(enable) {
				if (!options.pingEnable) return;

				var rgb = cw.HSLToRGB(cw.HSL(_hsl.h, 1, .5));
				var animOptions = {queue:options.pingQueue, duration:options.pingTime};

				function cssBoxShadow(blur, alpha) {
					function to24Bit(n) { return Math.round(n*255); }
					return {boxShadow: '0 0 ' +blur+ 'px rgba(' +$.map(rgb, to24Bit).join(',')+ ',' +alpha+ ')'};
				}

				_nodes.$slInput.stop(options.pingQueue, true);
			
				if (enable) {
					// looper function
					(function() {
						_nodes.$slInput
							.animate(cssBoxShadow(20, 1), animOptions)
							.animate(cssBoxShadow(15, .5), animOptions)
							.queue(options.pingQueue, arguments.callee)
							.dequeue(options.pingQueue)
					}).call();
				}
				else {
					_nodes.$slInput
						.animate(cssBoxShadow(5, 0), animOptions)
						.dequeue(options.pingQueue);
				}
			}

			/*
			 * Public methods (methods prefixed with underscore intended for internal use only)
			 */

			this.setCallback = function(f) { _callback = f; };

			this.setHSL = function(hsl) {
				if (!options.allowPartialSelection) {
					if (!cw.isCompleteHSL(hsl)) {
						throw new Error("Cannot use partial HSL object with allowPartialSelection option disabled");
					}
				}

				_hsl = hsl;
				this._update();
				_nodes.$root.trigger('change', this);
			};
			this.getHSL = function() { return _hsl; };

			this.getRoot = function() { return _nodes.$root; }

			this.isHueSelected = function() { return ('h' in _hsl); }
			this.isSLSelected = function() { return ('s' in _hsl && 'l' in _hsl); }

			this.canSetHue = function() { return options.allowHueSelection; }
			this.canSetSL = function() {
				if (!options.allowSLSelection) return false;

				if (options.allowPartialSelection) {
					return this.isHueSelected();
				}

				return true;
			}

			this._onColorMouseDown = function(e) {
				// Set which area is being clicked
				var coords = _coordsRelativeToCenter(e.pageX, e.pageY);
				if (Math.abs(coords.x) > _nodes.$slInput.width() / 2 ||
					Math.abs(coords.y) > _nodes.$slInput.height() / 2) {
					if (this.canSetHue()) {
						_selected = 'ring';
					}
				}
				else if (this.canSetSL()) {
					_selected = 'box';
				}

				if (_selected != 'none') {
					// Capture mouse
					$(document).bind('mousemove.cw', $.proxy(this._onDocumentDrag, this))
					           .bind('mouseup.cw', $.proxy(this._onDocumentMouseUp, this));

					// Pass event on to drag handler
					return this._onDocumentDrag(e);
				}
			};

			this._onDocumentMouseUp = function(e) {
				$(document).unbind('mousemove.cw')
				           .unbind('mouseup.cw');

				_selected = 'none';
				
				return false;
			};

			this._onDocumentDrag = function(e) {
				function toDegrees(radians) { return radians * 180/Math.PI; };
				function circular(position) { return (position + 360) % 360; }; // i.e. f(90) -> 90; f(-90) -> 270

				var coords = _coordsRelativeToCenter(e.pageX, e.pageY);
				var newHSL = {};

				// Set new HSL parameters
				if (_selected == 'ring') {
					$.extend(newHSL, _hsl, {h: circular(toDegrees(Math.atan2(coords.x, -coords.y)))});
				}
				else if (_selected == 'box') {
					// limits number to between 0 and 1
					function asPercentage(n) { return Math.max(0, Math.min(1, n)); }

					var s = asPercentage(.5 - coords.x/_nodes.$slInput.width());
					var l = asPercentage(.5 - coords.y/_nodes.$slInput.height());
					$.extend(newHSL, _hsl, {s:s, l:l});
				}

				if (typeof _callback == 'function') {
					var response = $.proxy(_callback, this, newHSL)();

					if (typeof response != 'undefined' && response !== true) {
						newHSL = response;
					}
				}

				if (newHSL) {
					this.setHSL(newHSL);
				}

				return false;
			};

			this._update = function() {
				if (this.canSetHue()) {
					_nodes.$hueInput.show();

					if (this.isHueSelected()) {
						var markerCoords = _markerCoordsForHue(_hsl.h);
						_nodes.$hueSwatch
							.css('background-color', cw.HSLToString(cw.HSL(_hsl.h, 1, .5)))
							.add(_nodes.$hueMarker)
							.css({left:markerCoords.x+'px', top:markerCoords.y+'px'})
							.show();
					}
					else {
						_nodes.$hueSwatch.hide();
						_nodes.$hueMarker.hide();
					}
				}
				else {
					_nodes.$hueMarker.hide();
					_nodes.$hueSwatch.hide();
					_nodes.$hueInput.hide();
				}

				if (this.canSetSL()) {
					_nodes.$slInput
						.css('background-color', cw.HSLToString(cw.HSL(_hsl.h, 1, .5)))
						.fadeIn(options.animationTime);

					_ping(false);

					if (this.isSLSelected()) {
						var markerCoords = _markerCoordsForSL(_hsl.s, _hsl.l);

						_nodes.$slSwatch
							.css('background-color', cw.HSLToString(_hsl))
							.add(_nodes.$slMarker)
							.css({left:markerCoords.x+'px', top:markerCoords.y+'px'})
							.show();
					}
					else {
						_ping(true);
						_nodes.$slSwatch.hide();
						_nodes.$slMarker.hide();
					}
				}
				else {
					_nodes.$slInput.hide();
					_nodes.$slMarker.hide();
					_nodes.$slSwatch.hide();
				}
			};

			/*
			 * Initialisation
			 */

			_nodes.$root  = $('\
				<div class="cw-colorwheel">\
					<div class="cw-h"/>\
					<div class="cw-sl"/>\
					<div class="cw-swatch cw-h-swatch"/>\
					<div class="cw-marker cw-h-marker"/>\
					<div class="cw-swatch cw-sl-swatch"/>\
					<div class="cw-marker cw-sl-marker"/>\
				</div>');

			// store reference to each node for quick access
			_nodes.$hueInput = _nodes.$root.find('.cw-h');
			_nodes.$hueMarker = _nodes.$root.find('.cw-h-marker');
			_nodes.$hueSwatch = _nodes.$root.find('.cw-h-swatch');
			_nodes.$slInput = _nodes.$root.find('.cw-sl');
			_nodes.$slMarker = _nodes.$root.find('.cw-sl-marker');
			_nodes.$slSwatch = _nodes.$root.find('.cw-sl-swatch');

			this._update(); // draw wheels with variables set as initialised

			// wait on user input
			_nodes.$root.bind('mousedown.cw', $.proxy(this._onColorMouseDown, this));
		}
	}

	// allows using $(':color-wheel') to find all elements that have had a ColorWheel
	// appended with $(el).colorWheel();
	$.expr[':']['color-wheel'] = function(el) {
		return (typeof $(el).data('colorWheel.cw') != 'undefined');
	};

	// automatically appends a colorwheel to the selected node, and stores a
	// reference to it in the node's data attribute
	$.fn.colorWheel = function(options) {
		return this.filter(':not(:color-wheel)').each(function(){
			var colorWheel = new cw.ColorWheel(options);
			$(this)
				.data('colorWheel.cw', colorWheel)
				.append(colorWheel.getRoot());
		});
	};

	return cw;
})(jQuery);
