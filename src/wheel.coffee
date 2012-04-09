# Color wheel functionality implemented in ColorWheel object
cw.ColorWheel = (options) ->
	options = $.extend({
		callback: null,
		defaultColor: new cw.HSL(),
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

	_hsl = options.defaultColor.toHSL()
	_callback = options.callback
	_nodes = {}
	_selected = 'none'

	# Private functions

	_coordsRelativeToCenter = (x, y) ->
		offset = _nodes.$root.offset()
		x: (x - offset.left) - _nodes.$root.width()/2
		y: (y - offset.top) - _nodes.$root.height()/2

	_markerCoordsForHue = (hue) ->
		wheelRadius = _nodes.$hueInput.width() / 2
		markerRailRadius = wheelRadius - options.inset
		hue *= Math.PI/180; # convert to radians
		x: Math.round Math.sin(hue) * markerRailRadius + wheelRadius
		y: Math.round -Math.cos(hue) * markerRailRadius + wheelRadius

	_markerCoordsForSL = (saturation, lightness) ->
		x: Math.round _nodes.$slInput.width() * (0.5 - saturation) + _nodes.$root.width()/2
		y: Math.round _nodes.$slInput.height() * (0.5 - lightness) + _nodes.$root.height()/2

	_ping = (enable) ->
		if (!options.pingEnable) then return

		animOptions = {queue:options.pingQueue, duration:options.pingTime}

		cssBoxShadow = (blur, alpha) ->
			{r, g, b} = (new cw.HSL(_hsl.h, 1, .5)).toRGB().to24Bit()
			boxShadow: "0 0 #{blur}px rgba(#{r},#{g},#{b},#{alpha})"

		_nodes.$slInput.stop(options.pingQueue, true)
	
		if enable
			# looper function
			do ->
				_nodes.$slInput
					.animate(cssBoxShadow(20, 1), animOptions)
					.animate(cssBoxShadow(15, .5), animOptions)
					.queue(options.pingQueue, arguments.callee)
					.dequeue(options.pingQueue)
		else
			_nodes.$slInput
				.animate(cssBoxShadow(5, 0), animOptions)
				.dequeue(options.pingQueue)

	# Public methods (methods prefixed with underscore intended for internal use only)

	this.setCallback = (f) -> _callback = f

	this.setHSL = (hsl) ->
		unless options.allowPartialSelection
			if hsl.isPartial()
				throw new Error("Cannot use partial HSL object with allowPartialSelection option disabled")

		_hsl = hsl
		this._update()
		_nodes.$root.trigger('change', this)

	this.getHSL = -> _hsl

	this.getRoot = -> _nodes.$root

	this.isHueSelected = -> _hsl.h?
	this.isSLSelected = -> _hsl.s? and _hsl.l?

	this.canSetHue = -> options.allowHueSelection
	this.canSetSL = ->
		options.allowSLSelection and (!options.allowPartialSelection or this.isHueSelected())

	this._onColorMouseDown = (e) =>
		# Set which area is being clicked
		coords = _coordsRelativeToCenter(e.pageX, e.pageY)
		if (Math.abs(coords.x) > _nodes.$slInput.width() / 2) or (Math.abs(coords.y) > _nodes.$slInput.height() / 2)
			if this.canSetHue()
				_selected = 'ring'
		else if this.canSetSL()
			_selected = 'box'

		unless _selected == 'none'
			# Capture mouse
			$(document).bind('mousemove.cw', this._onDocumentDrag)
			           .bind('mouseup.cw', this._onDocumentMouseUp)

			# Pass event on to drag handler
			this._onDocumentDrag(e)

	this._onDocumentMouseUp = (e) =>
		$(document).unbind('mousemove.cw')
		           .unbind('mouseup.cw')

		_selected = 'none'
		
		e.preventDefault()

	this._onDocumentDrag = (e) =>
		coords = _coordsRelativeToCenter(e.pageX, e.pageY)
		h = _hsl.h; s = _hsl.s; l = _hsl.l

		# Set new HSL parameters
		switch _selected
			when 'ring'
				toDegrees = (radians) -> radians * 180/Math.PI
				circular = (position) -> (position + 360) % 360 # i.e. f(90) -> 90; f(-90) -> 270

				h = circular toDegrees Math.atan2(coords.x, -coords.y)

			when 'box'
				asPercentage = (n) -> Math.max(0, Math.min(1, n)) # limits number to between 0 and 1

				s = asPercentage .5 - coords.x/_nodes.$slInput.width()
				l = asPercentage .5 - coords.y/_nodes.$slInput.height()

		if _callback?
			response = do $.proxy(_callback, this, new cw.HSL(h, s, l))

		unless response == false
			if response?.isColor()
				this.setHSL(response.toHSL())
			else
				this.setHSL(new cw.HSL(h, s, l))
				
		e.preventDefault()

	this._update = ->
		if this.canSetHue()
			_nodes.$hueInput.show()

			if this.isHueSelected()
				markerCoords = _markerCoordsForHue(_hsl.h)
				_nodes.$hueSwatch
					.css('background-color', new cw.HSL(_hsl.h, 1, .5))
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

		if this.canSetSL()
			_nodes.$slInput
				.css('background-color', new cw.HSL(_hsl.h, 1, .5))
				.fadeIn(options.animationTime)

			_ping(false)

			if this.isSLSelected()
				markerCoords = _markerCoordsForSL(_hsl.s, _hsl.l)

				_nodes.$slSwatch
					.css('background-color', _hsl)
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
	_nodes.$root.bind('mousedown.cw', this._onColorMouseDown)

	this

# allows using $(':color-wheel') to find all elements that have had a ColorWheel
# appended with $(el).colorWheel();
$.expr[':']['color-wheel'] = (el) ->
	$(el).data('colorWheel.cw')?

# automatically appends a colorwheel to the selected node, and stores a
# reference to it in the node's data attribute
$.fn.colorWheel = (options) ->
	this.filter(':not(:color-wheel)').each ->
		colorWheel = new cw.ColorWheel(options)
		$(this)
			.data('colorWheel.cw', colorWheel)
			.append(colorWheel.getRoot())

this.cw = cw # Set global reference
