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