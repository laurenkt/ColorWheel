###
Allows a reference to jQuery to be given if the jQuery name has been completely
altered (e.g. for people running multiple instances of jQuery).

Example:
	jQuery1p7 = jQuery.noConflict(true)
	jQuery1p7
		.when(jQuery1p7.getScript('cw-colorwheel.js'))
		.then(function() {
			// ColorWheel needs window.jQuery to function, and thus will not work here
			cw.jQuery(jQuery1p7)
			// ColorWheel now has a working reference to jQuery, and thus will work.
			jQuery1p7('div').colorWheel()
		})
###
cw.jQuery = (jQuery) ->
	$ = jQuery

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

cw.jQuery @jQuery