# Color wheel functionality implemented in ColorWheel object
class cw.ColorWheel
	constructor: (options) ->
		@options = $.extend({
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

		@_hsl = @options.defaultColor.toHSL()
		@_selected = 'none'
		
		@callback = @options.callback

		@$root    = $('<div class="cw-colorwheel" />')
		@$hue     = $('<div class="cw-h" />').appendTo @$root
		@$sl      = $('<div class="cw-sl" />').appendTo @$root
		@swatches =
			$hue:    $('<div class="cw-swatch" />').appendTo @$hue
			$sl:     $('<div class="cw-marker" />').appendTo @$hue
		@markers  =
			$hue:    $('<div class="cw-swatch" />').appendTo @$sl
			$sl:     $('<div class="cw-marker" />').appendTo @$sl

		this._update() # draw wheels with variables set as initialised

		# wait on user input
		@$root.bind('mousedown.cw', this._onColorMouseDown)

	_coordsRelativeToCenter: (x, y) ->
		offset = @$root.offset()
		x: x - offset.left - @$root.width()/2
		y: y - offset.top - @$root.height()/2

	_markerCoordsForHue: (hue) ->
		wheelRadius = @$hue.width() / 2
		markerRailRadius = wheelRadius - @options.inset
		hue *= Math.PI/180; # convert to radians
		x: Math.round Math.sin(hue) * markerRailRadius + wheelRadius
		y: Math.round -Math.cos(hue) * markerRailRadius + wheelRadius

	_markerCoordsForSL: (saturation, lightness) ->
		x: Math.round @$sl.width() * (1 - saturation)
		y: Math.round @$sl.height() * (1 - lightness)

	_ping: (enable = true) =>
		if (!@options.pingEnable) then return

		animOptions = {queue:@options.pingQueue, duration:@options.pingTime}

		cssBoxShadow = (blur, alpha) =>
			{r, g, b} = (new cw.HSL(@_hsl.h, 1, .5)).toRGB().to24Bit()
			boxShadow: "0 0 #{blur}px rgba(#{r},#{g},#{b},#{alpha})"

		@$sl.stop(@options.pingQueue, true)
	
		if enable
			# looper function
			do =>
				@$sl
					.animate(cssBoxShadow(20, 1), animOptions)
					.animate(cssBoxShadow(15, .5), animOptions)
					.queue(@options.pingQueue, arguments.callee)
					.dequeue(@options.pingQueue)
		else
			@$sl
				.animate(cssBoxShadow(5, 0), animOptions)
				.dequeue(@options.pingQueue)

	getHSL: -> @_hsl
	setHSL: (hsl) ->
		unless @options.allowPartialSelection
			if hsl.isPartial()
				throw new Error("Cannot use partial HSL object with allowPartialSelection option disabled")

		@_hsl = hsl
		this._update()
		@$root.trigger('change', this)

	isHueSelected: ->
		@_hsl.h?
	isSLSelected: ->
		@_hsl.s? and @_hsl.l?

	canSetHue: ->
		@options.allowHueSelection
	canSetSL: ->
		@options.allowSLSelection and (not @options.allowPartialSelection or this.isHueSelected())

	_onColorMouseDown: (e) =>
		# Set which area is being clicked
		coords = this._coordsRelativeToCenter(e.pageX, e.pageY)
		if (Math.abs(coords.x) > @$sl.width()/2) or (Math.abs(coords.y) > @$sl.height()/2)
			if this.canSetHue()
				@_selected = 'ring'
		else if this.canSetSL()
			@_selected = 'box'

		unless @_selected == 'none'
			# Capture mouse
			$(document).bind('mousemove.cw', this._onDocumentDrag)
			           .bind('mouseup.cw', this._onDocumentMouseUp)

			# Pass event on to drag handler
			this._onDocumentDrag(e)

	_onDocumentMouseUp: (e) =>
		$(document).unbind('mousemove.cw')
		           .unbind('mouseup.cw')

		@_selected = 'none'
		
		e.preventDefault()

	_onDocumentDrag: (e) =>
		coords = this._coordsRelativeToCenter(e.pageX, e.pageY)
		h = @_hsl.h; s = @_hsl.s; l = @_hsl.l

		# Set new HSL parameters
		switch @_selected
			when 'ring'
				toDegrees = (radians) -> radians * 180/Math.PI
				circular = (position) -> (position + 360) % 360 # i.e. f(90) -> 90; f(-90) -> 270

				h = circular toDegrees Math.atan2(coords.x, -coords.y)

			when 'box'
				asPercentage = (n) -> Math.max(0, Math.min(1, n)) # limits number to between 0 and 1

				s = asPercentage .5 - coords.x/@$sl.width()
				l = asPercentage .5 - coords.y/@$sl.height()

		if @callback?
			response = do $.proxy(@callback, this, new cw.HSL(h, s, l)) # invoke callback with 'this' context

		unless response == false
			if response?.isColor()
				this.setHSL(response.toHSL())
			else
				this.setHSL(new cw.HSL(h, s, l))
				
		e.preventDefault()

	_update: ->
		if this.canSetHue()
			@$hue.show()

			if this.isHueSelected()
				markerCoords = this._markerCoordsForHue(@_hsl.h)
				@swatches.$hue
					.css('background-color', new cw.HSL(@_hsl.h, 1, .5))
					.add(@markers.$hue)
					.css({left:markerCoords.x+'px', top:markerCoords.y+'px'})
					.show()
			else
				@swatches.$hue.hide()
				@markers.$hue.hide()
		else
			@markers.$hue.hide()
			@swatches.$hue.hide()
			@$hue.hide()

		if this.canSetSL()
			@$sl
				.css('background-color', new cw.HSL(@_hsl.h, 1, .5))
				.fadeIn(@options.animationTime)

			this._ping false

			if this.isSLSelected()
				markerCoords = this._markerCoordsForSL(@_hsl.s, @_hsl.l)

				@swatches.$sl
					.css('background-color', @_hsl)
					.add(@markers.$sl)
					.css({left:markerCoords.x+'px', top:markerCoords.y+'px'})
					.show()
			else
				this._ping()
				@swatches.$sl.hide()
				@markers.$sl.hide()
		else
			@$sl.hide()
			@swatches.$sl.hide()
			@markers.$sl.hide()

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
			.append(colorWheel.$root)

this.cw = cw # Set global reference
