# This file manages the projects reference to jQuery. It can be used to update
# the reference if jQuery isn't available on its usual namespace (`window.jQuery`).

# Reference to jQuery that is used throughout the project.
$ = {}

# Rebinds the project's reference to jQuery to the jQuery passed to this function,
# and installs the :color-wheel selector and $().colorWheel plug-in for the new
# reference.
cw.jQuery = (jQuery) ->
	$ = jQuery

	$.expr[':']['color-wheel'] = (el) ->
		el.colorWheel?

	# Creates a new ColorWheel, passing the given options, and automatically appends it to the
	# selected node by referencing it in the node's `data` attribute.
	$.fn.colorWheel = (options) ->
		for node in this when not node.colorWheel?
			node.colorWheel = new cw.ColorWheel(options)
			$(node).append(node.colorWheel.$root)
		this

# By default, set the instance of jQuery that CW will use to `window.jQuery`.
cw.jQuery @jQuery
