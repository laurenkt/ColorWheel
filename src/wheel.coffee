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
			hintEnable: false,
			hintQueue: 'hint.cw',
			hintTime: 500
		}, options)

		@_hsl = if @options.defaultColor?.isColor
			@options.defaultColor.toHSL()
		else
			cw.RGB.fromString(@options.defaultColor).toHSL()

		@_selected = 'none'
		
		@$root    = $('<div class="cw-colorwheel" />')
		@$hue     = $('<div class="cw-h" />').appendTo @$root
		@$sl      = $('<div class="cw-sl" />').appendTo @$root
		@swatches =
			$hue:    $('<div class="cw-swatch" />').appendTo @$hue
			$sl:     $('<div class="cw-swatch" />').appendTo @$sl
		@markers  =
			$hue:    $('<div class="cw-marker" />').appendTo @$hue
			$sl:     $('<div class="cw-marker" />').appendTo @$sl

		this.redraw() # draw wheels with variables set as initialised

		# wait on user input
		@$root.bind('mousedown.cw', this._onColorMouseDown)

	_coordsRelativeToCenter: (x, y) ->
		offset = @$root.offset()
		x: x - offset.left - @$root.width()/2
		y: y - offset.top - @$root.height()/2

	_markerCoordsForHue: (hue) ->
		outerRadius = @$hue.width()/2
		innerRadius = outerRadius - @options.inset
		x: Math.round (Math.sin(toRadians hue) * innerRadius) + outerRadius
		y: Math.round (-Math.cos(toRadians hue) * innerRadius) + outerRadius

	_markerCoordsForSL: (saturation, lightness) ->
		x: Math.round @$sl.width() * (1 - saturation)
		y: Math.round @$sl.height() * (1 - lightness)

	hintSL: (onOrOff = on) =>
		if not @options.hintEnable then return
		
		animOptions = {queue:@options.hintQueue, duration:@options.hintTime}

		cssBoxShadow = (blur, alpha) =>
			{r, g, b} = (new cw.HSL(@_hsl.h, 1, .5)).toRGB().to24Bit()
			boxShadow: "0 0 #{blur}px rgba(#{r},#{g},#{b},#{alpha})"

		@$sl.stop(@options.hintQueue, true)
	
		if onOrOff is on
			# looper function
			do =>
				@$sl
					.animate(cssBoxShadow(20, 1), animOptions)
					.animate(cssBoxShadow(15, .5), animOptions)
					.queue(@options.hintQueue, arguments.callee)
					.dequeue(@options.hintQueue)
		else
			@$sl
				.animate(cssBoxShadow(5, 0), animOptions)
				.dequeue(@options.hintQueue)

	getHSL: -> @_hsl
	setHSL: (hsl) ->
		unless @options.allowPartialSelection
			if hsl.isPartial()
				throw new Error("Cannot set partial HSL object with allowPartialSelection option disabled")

		@_hsl = hsl
		this.redraw()
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
		xy = this._coordsRelativeToCenter(e.pageX, e.pageY)
		if Math.abs(xy.x) > @$sl.width()/2 or Math.abs(xy.y) > @$sl.height()/2
			if this.canSetHue()
				@_selected = 'ring'
		else if this.canSetSL()
			@_selected = 'box'

		unless @_selected is 'none'
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
		xy = this._coordsRelativeToCenter(e.pageX, e.pageY)
		h = @_hsl.h; s = @_hsl.s; l = @_hsl.l

		# Set new HSL parameters
		switch @_selected
			when 'ring'
				h = circleWrap toDegrees Math.atan2(xy.x, -xy.y)

			when 'box'
				s = asPercentage .5 - xy.x/@$sl.width()
				l = asPercentage .5 - xy.y/@$sl.height()

		if @options.callback?
			response = do $.proxy(@options.callback, this, new cw.HSL(h, s, l)) # invoke callback with 'this' context

		if response isnt false
			if response?.isColor
				this.setHSL(response.toHSL())
			else
				this.setHSL(new cw.HSL(h, s, l))
				
		e.preventDefault()

	redraw: ->
		if this.canSetHue()
			@$hue.show()

			if this.isHueSelected()
				xy = this._markerCoordsForHue(@_hsl.h)
				@swatches.$hue
					.css('background-color', new cw.HSL(@_hsl.h, 1, .5))
					.add(@markers.$hue)
					.css({left:xy.x+'px', top:xy.y+'px'})
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

			this.hintSL off

			if this.isSLSelected()
				xy = this._markerCoordsForSL(@_hsl.s, @_hsl.l)

				@swatches.$sl
					.css('background-color', @_hsl)
					.add(@markers.$sl)
					.css({left:xy.x+'px', top:xy.y+'px'})
					.show()
			else
				this.hintSL on
				@swatches.$sl.hide()
				@markers.$sl.hide()
		else
			@$sl.hide()
			@swatches.$sl.hide()
			@markers.$sl.hide()