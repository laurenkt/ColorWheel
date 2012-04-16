cw = {}

# Store a reference to whatever was previously at `window.cw` before assigning `window.cw` as our own object, so that it can be restored by the `cw.noConflict()` method if necessary.
__noConflict = @cw
@cw = cw

# Returns control of the `cw` global back to its original owner,
# and returns a reference to CW so the callee can assign it to a new name.
#
# Example usage:
#
# 	var CWLib = cw.noConflict()
cw.noConflict = =>
	@cw = __noConflict
	cw
