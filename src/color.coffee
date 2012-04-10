class cw.Color
	constructor: ->
		@isColor = yes

class cw.RGB extends cw.Color
	constructor: (@r, @g, @b) ->
		super
	
	isTransparent: ->
		not (@r? or @g? or @b?)
	
	toRGB: ->
		new cw.RGB(@r, @g, @b)

	toHSL: ->
		if this.isTransparent() then return new cw.HSL()

		max = Math.max @r, @g, @b
		min = Math.min @r, @g, @b
		chroma = max - min
		
		if chroma is 0
			new cw.HSL(undefined, 0, max) # achromatic
		else
			h = 60 * switch max # determine where on which side h lies, and *60 to convert to circular
				when @r then (@g - @b)/chroma % 6
				when @g then (@b - @r)/chroma + 2
				when @b then (@r - @g)/chroma + 4

			l = (max + min)/2 # average of largest and smallest components
			s = chroma/(1 - Math.abs(2*l - 1))

			new cw.HSL(h, s, l)
	
	# plain obj with components in the form 0..255 rather than 0..1
	to24Bit: ->
		r: Math.round @r*255
		g: Math.round @g*255
		b: Math.round @b*255

	toString: ->
		if this.isTransparent()
			'transparent'
		else # convert to #aabbcc hex representation
			{r, g, b} = this.to24Bit()
			toByte = (value) -> ('0' + value.toString(16)).slice(-2)
			"##{toByte r}#{toByte g}#{toByte b}"
	
	@fromString: (string) ->
		if string.toLowerCase() is 'transparent'
			new cw.RGB()
		else
			# can be of form #rgb or #rrggbb
			switch string.length
				when 7 then f = (i) -> parseInt(string.substring(i*2 + 1, i*2 + 3), 16) / 255
				when 4 then f = (i) -> parseInt(string[i+1], 16) / 15
				else throw new Error("CSS color '#{string}' not valid")
			
			new cw.RGB(f(0), f(1), f(2))

class cw.HSL extends cw.Color
	constructor: (@h, @s, @l) ->
		super

	isPartial: ->
		not (@h? and @s? and @l?)
	
	isTransparent: ->
		not (@h? or @s? or @l?)

	toHSL: ->
		new cw.HSL(@h, @s, @l)

	toRGB: ->
		if this.isTransparent() then return new cw.RGB()

		h = @h / 60; # convert from circlular to hexagonal representation, h represents side

		# sensible defaults for missing sl values
		s = @s ? 1
		l = @l ? 0.5

		chroma = (1 - Math.abs(2*l - 1)) * s
		min = l - chroma/2 # find smallest component
		mid = chroma * (1 - Math.abs(h%2 - 1)) # find middle component
		
		# should be one of 6 sides of the hexagon, or NaN
		[r, g, b] = switch Math.floor(h)
			when 0 then [chroma, mid, 0]
			when 1 then [mid, chroma, 0]
			when 2 then [0, chroma, mid]
			when 3 then [0, mid, chroma]
			when 4 then [mid, 0, chroma]
			when 5 then [chroma, 0, mid]
			else [l, l, l] # no hue-achromatic

		new cw.RGB(r+min, g+min, b+min) # RGB components equally lightened by smallest component

	toString: ->
		this.toRGB().toString()

	@fromString: (string) ->
		cw.RGB.fromString(string).toHSL()
