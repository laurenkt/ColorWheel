class cw.Color

class cw.RGB extends cw.Color
	@names = {
		aliceblue:[240,248,255], antiquewhite:[250,235,215], aqua:[0,255,255],
		aquamarine:[127,255,212], azure:[240,255,255], beige:[245,245,220],
		bisque:[255,228,196], black:[0,0,0], blanchedalmond:[255,235,205],
		blue:[0,0,255], blueviolet:[138,43,226], brown:[165,42,42], burlywood:[222,184,135],
		cadetblue:[95,158,160], chartreuse:[127,255,0], chocolate:[210,105,30],
		coral:[255,127,80], cornflowerblue:[100,149,237], cornsilk:[255,248,220],
		crimson:[220,20,60], cyan:[0,255,255], darkblue:[0,0,139], darkcyan:[0,139,139],
		darkgoldenrod:[184,134,11], darkgray:[169,169,169], darkgrey:[169,169,169],
		darkgreen:[0,100,0], darkkhaki:[189,183,107], darkmagenta:[139,0,139],
		darkolivegreen:[85,107,47], darkorange:[255,140,0], darkorchid:[153,50,204],
		darkred:[139,0,0], darksalmon:[233,150,122], darkseagreen:[143,188,143],
		darkslateblue:[72,61,139], darkslategray:[47,79,79], darkslategrey:[47,79,79],
		darkturquoise:[0,206,209], darkviolet:[148,0,211], deeppink:[255,20,147],
		deepskyblue:[0,191,255], dimgray:[105,105,105], dimgrey:[105,105,105],
		dodgerblue:[30,144,255], firebrick:[178,34,34], floralwhite:[255,250,240],
		forestgreen:[34,139,34], fuchsia:[255,0,255], gainsboro:[220,220,220],
		ghostwhite:[248,248,255], gold:[255,215,0], goldenrod:[218,165,32],
		gray:[128,128,128], grey:[128,128,128], green:[0,128,0], greenyellow:[173,255,47],
		honeydew:[240,255,240], hotpink:[255,105,180], indianred:[205,92,92],
		indigo:[75,0,130], ivory:[255,255,240], khaki:[240,230,140], lavender:[230,230,250],
		lavenderblush:[255,240,245], lawngreen:[124,252,0], lemonchiffon:[255,250,205],
		lightblue:[173,216,230], lightcoral:[240,128,128], lightcyan:[224,255,255],
		lightgoldenrodyellow:[250,250,210], lightgray:[211,211,211], lightgrey:[211,211,211],
		lightgreen:[244,238,144], lightpink:[255,182,193], lightsalmon:[255,160,122],
		lightseagreen:[32,178,170], lightskyblue:[135,206,250], lightslategray:[119,136,153],
		lightslategrey:[119,136,153], lightsteelblue:[176,196,222], lightyellow:[255,255,224],
		lime:[0,255,0], limegreen:[50,205,50], linen:[250,240,230], magenta:[255,0,255],
		maroon:[128,0,0], mediumaquamarine:[102,205,170], mediumblue:[0,0,205],
		mediumorchid:[186,85,211], mediumpurple:[147,112,219], mediumseagreen:[60,179,133],
		mediumslateblue:[123,104,238], mediumspringgreen:[0,250,154], mediumturquoise:[72,209,204],
		mediumvioletred:[199,21,133], midnightblue:[25,25,112], mintcream:[245,255,250],
		mistyrose:[255,228,225], moccasin:[255,228,181], navajowhite:[255,222,173],
		navy:[0,0,128], oldlace:[253,245,230], olive:[128,128,0], olivedrab:[107,142,35],
		orange:[255,165,0], orangered:[255,69,0], orchid:[218,112,214], palegoldenrod:[238,232,170],
		palegreen:[152,251,152], paleturquoise:[175,238,238], palevioletred:[219,112,147],
		papayawhip:[255,239,213], peachpuff:[255,218,185], peru:[205,133,63], pink:[255,192,203],
		plum:[221,160,221], powderblue:[176,224,230], purple:[128,0,128], red:[255,0,0],
		rosybrow:[188,143,143], royalblue:[65,105,225], saddlebrown:[169,69,16],
		salmon:[250,128,114], sandybrown:[224,164,96], seagreen:[46,139,87], seashell:[255,145,238],
		sienna:[160,82,45], silver:[192,192,192], skyblue:[135,206,235], slateblue:[106,90,205],
		slategray:[112,128,144], slategrey:[112,128,144], snow:[255,250,250],
		springgreen:[0,255,127], steelblue:[70,130,180], tan:[210,180,140], teal:[0,128,128],
		thistle:[216,191,216], tomato:[255,99,71], turquoise:[64,244,208], violet:[238,130,238],
		wheat:[245,222,179], white:[255,255,255], whitesmoke:[245,245,245], yellow:[255,255,0],
		yellowgreen:[145,205,50]
	}

	constructor: (@r, @g, @b) ->
	
	isTransparent: =>
		not (@r? or @g? or @b?)
	
	toRGB: => this

	toHSL: =>
		if this.isTransparent() then return new cw.HSL()

		r = rgb.r; g = rgb.g; b = rgb.b

		max = Math.max(r, g, b)
		min = Math.min(r, g, b)
		chroma = max - min
		
		l = (max + min)/2 # average of largest and smallest components

		if (chroma == 0) then return new cw.HSL(undefined, 0, l) # achromatic

		if      max is r then h = (g - b)/chroma % 6
		else if max is g then h = (b - r)/chroma + 2
		else if max is b then h = (r - g)/chroma + 4

		h *= 60; # convert from hexagonal representaiton to circular
		s = chroma/(1 - Math.abs(2*l - 1))

		new cw.HSL(h, s, l)
	
	toString: =>
		if this.isTransparent() then return 'transparent'

		toHex = (rgbValue) ->
			rgbValue *= 255 # convert to 24-bit color space
			if rgbValue < 16
				'0' + Math.round(rgbValue).toString(16)
			else
				Math.round(rgbValue).toString(16)

		"##{toHex(rgb.r)}#{toHex(rgb.g)}#{toHex(rgb.b)}"
	
	@fromName: (name) ->
		[r, g, b] = @names[name.toLowerCase()]
		if r?
			new cw.RGB(r, g, b)
		else
			throw new Error("CSS color name '#{name}' not recognised")
	
	@fromHex: (string) ->
		# can be of form #rgb or #rrggbb
		switch string.length
			when 7 then byte = (i) -> parseInt(string.substring(i*2 + 1, i*2 + 3), 16) / 255
			when 4 then byte = (i) -> parseInt(string[i+1], 16) / 15
			else throw new Error("CSS color '#{string}' not valid")
		
		new cw.RGB(byte(0), byte(1), byte(2))

	@fromString: (string) ->
		if string.toLowerCase() == 'translucent'
			new cw.RGB()
		else if string[0] == '#'
			cw.RGB::fromHex(string)
		else
			cw.RGB::fromName(string)

class cw.HSL extends cw.Color
	constructor: (@h, @s, @l) ->

	isPartial: =>
		@h? and @s? and @l?
	
	isTransparent: =>
		not (@h? or @s? or @l?)

	toHSL: => this

	toRGB: =>
		if this.isTransparent() then return new cw.RGB()

		# sensible defaults for partial hsl value
		s = hsl.s ? 1
		l = hsl.l ? 0.5

		h = hsl.h / 60; # convert from circlular to hexagonal representation, h represents side

		chroma = (1 - Math.abs(2*l - 1)) * s
		min = l - chroma/2 # find smallest component
		mid = chroma * (1 - Math.abs(h%2 - 1)) # find middle component
		
		# returns RGB value equally lightened by smallest component
		f = (r, g, b) -> new cw.RGB(r+min, g+min, b+min)

		if      0 <= h < 1 then f(chroma, mid, 0)
		else if 1 <= h < 2 then f(mid, chroma, 0)
		else if 2 <= h < 3 then f(0, chroma, mid)
		else if 3 <= h < 4 then f(0, mid, chroma)
		else if 4 <= h < 5 then f(mid, 0, chroma)
		else if 5 <= h < 6 then f(chroma, 0, mid)
		else                    f(l, l, l); # defaul

	toString: =>
		this.toRGB().toString()

	@fromString: (string) ->
		cw.RGB::fromString(string).toHSL()
