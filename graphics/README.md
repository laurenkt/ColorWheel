Making your own sprites
=======================

The hue.eps file is an EPS script which generates a hue gradient from 0 degrees (red) all the way back round to 360 degrees (red again). This can be trivially made into a hue wheel. You can edit the EPS script yourself if the resolution is not sufficient.

1. Load hue.eps into your favourite graphics editing programme
2. Use a polar coordinates filter (in Photoshop: Filter->Distort->Polar Coordinates...)
3. Make sure the resulting image is aligned/rotated properly. Flip/rotate it if necessary. Red should be at 0 (the top), green at roughly 120 (clockwise), blue at roughly 240 (clockwise).
4. Cut the result into a wheel shape. Using Layer Masks is a good way to achieve this non-destructively.

For the saturation/lightness gradient:

1. Create a selection for the size of box you want (I use 100px by 100px)
2. Use a fill command with a gradient from 0% opacity, #808080, to 100% opacity #808080, from left to right. If you're using Photoshop, make sure the smoothness of the gradient is set to 0 to get an accurate gradient
3. On a layer above, using the same selection, use a fill command from top to bottom with the following gradient (also smoothness 0 in Photoshop):
	1. Position 0. 100% opacity. #FFFFFF
	2. Position 50. 0% opacity. #FFFFFF
	3. Position 50. 0% opacity. #000000
	4. Position 100. 100% opacity. #000000

For the marker:

I used a white circle, with a smaller black circle inside it, with the centre cut out.
