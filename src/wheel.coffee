cw =
	# Constructors

	RGB: (r, g, b) ->
		if (arguments.length == 0) then return null
		return {r:r, g:g, b:b}

	HSL: (h, s, l) ->
		if (arguments.length == 0) then return {}
		return {h:h, s:s, l:l}

	# Type Identifiers

	isRGB: (rgb) ->
		rgb == null or
		($.isPlainObject(rgb) and rgb.r? and rgb.g? and rgb.b?)

	isHSL: (hsl) ->
		$.isPlainObject(hsl) and
		($.isEmptyObject(hsl) or hsl.h? or hsl.s? or hsl.l?)

	isCompleteHSL: (hsl) ->
		$.isPlainObject(hsl) and hsl.h? and hsl.s? and hsl.l?

	isColorString: (str) ->
		return typeof str == 'string' and
			   (str == 'transparent' or
			   (str[0] == '#' and (str.length == 4 || str.length == 7)))

	# Type Coercion

	colorToRGB: (color) ->
		if (cw.isRGB(color)) then return color
		if (cw.isHSL(color)) then return cw.HSLToRGB(color)
		if (cw.isColorString(color)) then return cw.stringToRGB(color)

	colorToHSL: (color) ->
		if (cw.isHSL(color)) then return color
		if (cw.isRGB(color)) then return cw.RGBToHSL(color)
		if (cw.isColorString(color)) then return cw.stringToHSL(color)

	colorToString: (color) ->
		if (cw.isColorString(color)) then return color
		if (cw.isHSL(color)) then return cw.HSLToString(color)
		if (cw.isRGB(color)) then return cw.RGBToString(color)

	HSLToRGB: (hsl) ->
		if ($.isEmptyObject(hsl)) then return null

		# sensible defaults for partial hsl value
		hsl = $.extend({s:1, l:0.5}, hsl)
		h = hsl.h; s = hsl.s; l = hsl.l

		h /= 60; # convert from circlular to hexagonal representation, h represents side

		chroma = (1 - Math.abs(2*l - 1)) * s
		min = l - chroma/2 # find smallest component
		mid = chroma * (1 - Math.abs(h%2 - 1)) # find middle component
		
		# returns RGB value equally lightened by smallest component
		f = (r, g, b) -> cw.RGB(r+min, g+min, b+min)

		if      0 <= h < 1 then f(chroma, mid, 0)
		else if 1 <= h < 2 then f(mid, chroma, 0)
		else if 2 <= h < 3 then f(0, chroma, mid)
		else if 3 <= h < 4 then f(0, mid, chroma)
		else if 4 <= h < 5 then f(mid, 0, chroma)
		else if 5 <= h < 6 then f(chroma, 0, mid)
		else                    f(l, l, l); # defaul

	RGBToHSL: (rgb) ->
		if (rgb == null) then return {}

		r = rgb.r; g = rgb.g; b = rgb.b

		max = Math.max(r, g, b)
		min = Math.min(r, g, b)
		chroma = max - min
		
		l = (max + min)/2 # average of largest and smallest components

		if (chroma == 0) then return {s:0, l:l} # achromatic

		if      max is r then h = (g - b)/chroma % 6
		else if max is g then h = (b - r)/chroma + 2
		else if max is b then h = (r - g)/chroma + 4

		h *= 60; # convert from hexagonal representaiton to circular
		s = chroma/(1 - Math.abs(2*l - 1))

		return cw.HSL(h, s, l)

	RGBToString: (rgb) ->
		if (rgb == null) then return 'transparent'

		decToHexByte = (decByte) ->
			if (decByte < 16)
				return '0' + Math.round(decByte).toString(16)

			return Math.round(decByte).toString(16)

		return '#' + decToHexByte(rgb.r * 255) +
					 decToHexByte(rgb.g * 255) +
					 decToHexByte(rgb.b * 255)

	HSLToString: (hsl) -> cw.RGBToString(cw.HSLToRGB(hsl))

	stringToRGB: (string) ->
		if (string == 'transparent') then return null
		
		extract = (part) -> return parseInt(string.substring(part*2 + 1, part*2 + 3), 16) / 255

		# use a different extract if form is #abc
		if (string.length == 4)
			extract = (part) -> return parseInt(string[part+1], 16) / 15
		
		return cw.RGB(extract(0), extract(1), extract(2))

	stringToHSL: (string) -> return cw.RGBToHSL(cw.stringToRGB(string))

	# Color wheel functionality implemented in ColorWheel object
	ColorWheel: (options) ->
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
		}, options)

		# Private variables

		_hsl = cw.colorToHSL(options.defaultColor)
		_callback = options.callback
		_nodes = {}
		_selected = 'none'

		# Private functions

		_coordsRelativeToCenter = (x, y) ->
			offset = _nodes.$root.offset()
			{x: (x - offset.left) - _nodes.$root.width()/2, y: (y - offset.top) - _nodes.$root.height()/2}

		_markerCoordsForHue = (hue) ->
			wheelRadius = _nodes.$hueInput.width() / 2
			markerRailRadius = wheelRadius - options.inset

			hue *= Math.PI/180; # convert to radians

			x = Math.sin(hue) * markerRailRadius + wheelRadius
			y = -Math.cos(hue) * markerRailRadius + wheelRadius

			return {x:Math.round(x), y:Math.round(y)}

		_markerCoordsForSL = (saturation, lightness) ->
			x = _nodes.$slInput.width() * (0.5 - saturation) + _nodes.$root.width()/2
			y = _nodes.$slInput.height() * (0.5 - lightness) + _nodes.$root.height()/2

			return {x:Math.round(x), y:Math.round(y)}

		_ping = (enable) ->
			if (!options.pingEnable) then return

			rgb = cw.HSLToRGB(cw.HSL(_hsl.h, 1, .5))
			animOptions = {queue:options.pingQueue, duration:options.pingTime}

			cssBoxShadow = (blur, alpha) ->
				to24Bit = (n) -> return Math.round(n*255)
				return {boxShadow: '0 0 ' +blur+ 'px rgba(' +$.map(rgb, to24Bit).join(',')+ ',' +alpha+ ')'}

			_nodes.$slInput.stop(options.pingQueue, true)
		
			if (enable)
				# looper function
				(() ->
					_nodes.$slInput
						.animate(cssBoxShadow(20, 1), animOptions)
						.animate(cssBoxShadow(15, .5), animOptions)
						.queue(options.pingQueue, arguments.callee)
						.dequeue(options.pingQueue)
				).call()
			else
				_nodes.$slInput
					.animate(cssBoxShadow(5, 0), animOptions)
					.dequeue(options.pingQueue)

		# Public methods (methods prefixed with underscore intended for internal use only)

		this.setCallback = (f) -> _callback = f

		this.setHSL = (hsl) ->
			if (!options.allowPartialSelection)
				if (!cw.isCompleteHSL(hsl))
					throw new Error("Cannot use partial HSL object with allowPartialSelection option disabled")

			_hsl = hsl
			this._update()
			_nodes.$root.trigger('change', this)
		this.getHSL = () -> return _hsl

		this.getRoot = () -> return _nodes.$root

		this.isHueSelected = () -> return (_hsl.h?)
		this.isSLSelected = () -> return (_hsl.s? and _hsl.l?)

		this.canSetHue = () -> return options.allowHueSelection
		this.canSetSL = () ->
			if (!options.allowSLSelection) then return false

			if (options.allowPartialSelection)
				return this.isHueSelected()

			return true

		this._onColorMouseDown = (e) ->
			# Set which area is being clicked
			coords = _coordsRelativeToCenter(e.pageX, e.pageY)
			if (Math.abs(coords.x) > _nodes.$slInput.width() / 2) or (Math.abs(coords.y) > _nodes.$slInput.height() / 2)
				if (this.canSetHue())
					_selected = 'ring'
			else if (this.canSetSL())
				_selected = 'box'

			if (_selected != 'none')
				# Capture mouse
				$(document).bind('mousemove.cw', $.proxy(this._onDocumentDrag, this))
						   .bind('mouseup.cw', $.proxy(this._onDocumentMouseUp, this))

				# Pass event on to drag handler
				return this._onDocumentDrag(e)

		this._onDocumentMouseUp = (e) ->
			$(document).unbind('mousemove.cw')
					   .unbind('mouseup.cw')

			_selected = 'none'
			
			return false

		this._onDocumentDrag = (e) ->
			toDegrees = (radians) -> return radians * 180/Math.PI
			circular = (position) -> return (position + 360) % 360 # i.e. f(90) -> 90; f(-90) -> 270

			coords = _coordsRelativeToCenter(e.pageX, e.pageY)
			newHSL = {}

			# Set new HSL parameters
			if (_selected == 'ring')
				$.extend(newHSL, _hsl, {h: circular(toDegrees(Math.atan2(coords.x, -coords.y)))})
			else if (_selected == 'box')
				# limits number to between 0 and 1
				asPercentage = (n) -> return Math.max(0, Math.min(1, n))

				s = asPercentage(.5 - coords.x/_nodes.$slInput.width())
				l = asPercentage(.5 - coords.y/_nodes.$slInput.height())
				$.extend(newHSL, _hsl, {s:s, l:l})

			if (typeof _callback == 'function')
				response = $.proxy(_callback, this, newHSL)()

				if (response? and response != true)
					newHSL = response

			if (newHSL)
				this.setHSL(newHSL)

			return false

		this._update = () ->
			if (this.canSetHue())
				_nodes.$hueInput.show()

				if (this.isHueSelected())
					markerCoords = _markerCoordsForHue(_hsl.h)
					_nodes.$hueSwatch
						.css('background-color', cw.HSLToString(cw.HSL(_hsl.h, 1, .5)))
						.add(_nodes.$hueMarker)
						.css({left:markerCoords.x+'px', top:markerCoords.y+'px'})
						.show()
				else
					_nodes.$hueSwatch.hide()
					_nodes.$hueMarker.hide()
			else
				_nodes.$hueMarker.hide()
				_nodes.$hueSwatch.hide()
				_nodes.$hueInput.hide()

			if (this.canSetSL())
				_nodes.$slInput
					.css('background-color', cw.HSLToString(cw.HSL(_hsl.h, 1, .5)))
					.fadeIn(options.animationTime)

				_ping(false)

				if (this.isSLSelected())
					markerCoords = _markerCoordsForSL(_hsl.s, _hsl.l)

					_nodes.$slSwatch
						.css('background-color', cw.HSLToString(_hsl))
						.add(_nodes.$slMarker)
						.css({left:markerCoords.x+'px', top:markerCoords.y+'px'})
						.show()
				else
					_ping(true)
					_nodes.$slSwatch.hide()
					_nodes.$slMarker.hide()
			else
				_nodes.$slInput.hide()
				_nodes.$slMarker.hide()
				_nodes.$slSwatch.hide()

		# Initialisation

		_nodes.$root = $("""
		                 <div class="cw-colorwheel">\
		                 	<div class="cw-h"/>\
		                 	<div class="cw-sl"/>\
		                 	<div class="cw-swatch cw-h-swatch"/>\
		                 	<div class="cw-marker cw-h-marker"/>\
		                 	<div class="cw-swatch cw-sl-swatch"/>\
		                 	<div class="cw-marker cw-sl-marker"/>\
		                 </div>
		                 """)

		# store reference to each node for quick access
		_nodes.$hueInput = _nodes.$root.find('.cw-h')
		_nodes.$hueMarker = _nodes.$root.find('.cw-h-marker')
		_nodes.$hueSwatch = _nodes.$root.find('.cw-h-swatch')
		_nodes.$slInput = _nodes.$root.find('.cw-sl')
		_nodes.$slMarker = _nodes.$root.find('.cw-sl-marker')
		_nodes.$slSwatch = _nodes.$root.find('.cw-sl-swatch')

		this._update() # draw wheels with variables set as initialised

		# wait on user input
		_nodes.$root.bind('mousedown.cw', $.proxy(this._onColorMouseDown, this))

		this


# allows using $(':color-wheel') to find all elements that have had a ColorWheel
# appended with $(el).colorWheel();
$.expr[':']['color-wheel'] = (el) ->
	return (typeof $(el).data('colorWheel.cw') != 'undefined')

# automatically appends a colorwheel to the selected node, and stores a
# reference to it in the node's data attribute
$.fn.colorWheel = (options) ->
	return this.filter(':not(:color-wheel)').each () ->
		colorWheel = new cw.ColorWheel(options)
		$(this)
			.data('colorWheel.cw', colorWheel)
			.append(colorWheel.getRoot())

this.cw = cw # Set global reference
