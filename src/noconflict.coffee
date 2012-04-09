# Variables referenced through CW, must be declared at front
cw = {}
$ = {}

# Store a reference to old window.cw, and then replace
__noConflict = @cw
@cw = cw

###
Returns control of the 'cw' variable back to its original owner, and returns a
reference to ColorWheel so a new name can be given.

Example:
	var CWLib = cw.noConflict()
###
cw.noConflict = =>
	@cw = __noConflict
	cw # return cw so that cw can be set to a different namespace
