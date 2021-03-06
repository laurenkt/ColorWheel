toDegrees = (radians) ->
	radians * 180/Math.PI

toRadians = (degrees) ->
	degrees * Math.PI/180

# constrains n to between 0 and 1
# e.g. f(3) -> 1, f(1) ->, f(0) -> 0, f(0.5) -> 0.5
asPercentage = (n) ->
	Math.max(0, Math.min(1, n))

# wraps position around 360,
# i.e. f(90) -> 90; f(-90) -> 270
circleWrap = (position) ->
	(position + 360) % 360

# Color wheel functionality implemented in ColorWheel object
class cw.ColorWheel
	constructor: (options) ->
		@options = $.extend(
			callback: null
			defaultColor: new cw.HSL()
			inset: 10
			allowPartialSelection: true
			allowHueSelection: true
			allowSLSelection: true
			SLHiddenWhenNoHue: true
			animationTime: 200
			hintEnable: false
			hintQueue: 'hint.cw'
			hintTime: 500
		, options)

		@_hsl = if @options.defaultColor?.isColor
			@options.defaultColor.toHSL()
		else
			cw.HSL.fromString @options.defaultColor

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

		# draw wheels with variables set as initialised
		this.redraw()

		# wait on user input
		@$root.bind('mousedown.cw', this._onMouseDown)
		@$hue.bind('mousedown.cw', this._onHueMouseDown)
		@$sl.bind('mousedown.cw', this._onSLMouseDown)

	hintSL: (onOrOff = on) =>
		if not @options.hintEnable then return
		
		animOptions = queue: @options.hintQueue, duration: @options.hintTime

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

	getHSL: -> @_hsl.toHSL()
	setHSL: (hsl) ->
		unless @options.allowPartialSelection
			if hsl.isPartial()
				throw new Error("Setting partial HSL object when allowPartialSelection:false")
	
		@_hsl = hsl
		this.redraw()
		@$root.trigger('change', [this.getHSL(), this])

	isHueSelected: ->
		@_hsl.h?
	isSLSelected: ->
		@_hsl.s? or @_hsl.l?

	canSetHue: ->
		@options.allowHueSelection
	canSetSL: ->
		@options.allowSLSelection and
		(not this.canSetHue() or
		 not @options.allowPartialSelection or
		 not @options.SLHiddenWhenNoHue or
		 this.isHueSelected())

	_onHueMouseDown: =>
		if this.canSetHue()
			@_selected = 'ring'
		
	_onSLMouseDown: =>
		if this.canSetSL()
			@_selected = 'box'

	_onMouseDown: (e) =>
		if @_selected isnt 'none'
			# Capture mouse
			$(document)
				.bind('mousemove.cw', this._onDocumentDrag)
				.bind('mouseup.cw', this._onDocumentMouseUp)

			# Pass event on to drag handler
			this._onDocumentDrag(e)

		e.preventDefault()

	_onDocumentMouseUp: (e) =>
		$(document)
			.unbind('mousemove.cw')
			.unbind('mouseup.cw')

		@_selected = 'none'
		
		e.preventDefault()

	_onDocumentDrag: (e) =>
		# Find x/y coords from center
		x = e.pageX - @$root.offset().left - @$root.width()/2
		y = e.pageY - @$root.offset().top - @$root.height()/2
		h = @_hsl.h; s = @_hsl.s; l = @_hsl.l

		# Set new HSL parameters
		switch @_selected
			when 'ring'
				h = circleWrap toDegrees Math.atan2(x, -y)

			when 'box'
				s = asPercentage .5 - x/@$sl.width()
				l = asPercentage .5 - y/@$sl.height()

		if @options.callback?
			# invoke callback with 'this' context
			response = do $.proxy(@options.callback, this, new cw.HSL(h, s, l))

		if response isnt false
			if response?.isColor
				this.setHSL(response.toHSL())
			else
				this.setHSL(new cw.HSL(h, s, l))
				
		e.preventDefault()

	redraw: ->
		@$hue.toggle this.canSetHue()

		if this.isHueSelected()
			outerRadius = @$hue.width()/2
			innerRadius = outerRadius - @options.inset

			position =
				top: Math.round (-Math.cos(toRadians @_hsl.h) * innerRadius) + outerRadius
				left: Math.round (Math.sin(toRadians @_hsl.h) * innerRadius) + outerRadius

			@swatches.$hue
				.css('background-color', new cw.HSL(@_hsl.h, 1, .5))
				.add(@markers.$hue)
				.css(position)
				.show()
		else
			@swatches.$hue.hide()
			@markers.$hue.hide()

		if this.canSetSL()
			@$sl
				.css('background-color', new cw.HSL(@_hsl.h, 1, .5))
				.fadeIn(@options.animationTime)
		else
			@$sl.hide()

		if this.isSLSelected() or @hasBeenSet
			position =
				top: Math.round @$sl.height() * (1 - (@_hsl.l ? 0.5))
				left: Math.round @$sl.width() * (1 - (@_hsl.s ? 1))
			
			@swatches.$sl
				.css('background-color', @_hsl)
				.add(@markers.$sl)
				.css(position)
				.show()
		else
			@swatches.$sl.hide()
			@markers.$sl.hide()
		
		this.hintSL(this.canSetSL() and not this.isSLSelected())
