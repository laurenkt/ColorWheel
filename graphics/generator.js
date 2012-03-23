#!/usr/bin/env node

var util = require('util');
var argv = require('optimist')
	.usage('Usage: $0 -d [num] -w [num] -s [num]')
	.options('s', {
		demand: true,
		alias: 'square-size',
		describe: 'Size (length and height) of the saturation/lightness and white background squares (in pixels)'
	})
	.options('d', {
		demand: true,
		alias: 'wheel-diameter',
		describe: 'Outer diameter of the hue wheel (in pixels)'
	})
	.options('w', {
		demand: true,
		alias: 'wheel-width',
		describe: 'Width of the visible band of the hue wheel (in pixels)'
	})
	.options('l', {
		default: 1800,
		alias: 'lines-to-draw',
		describe: 'Number of lines that will comprise the hue wheel (for larger images more lines will increase detail)'
	})
	.options('mw', {
		default: 15,
		alias: 'marker-white-diameter',
		describe: 'Diameter of the white portion of the selected colour marker (in pixels)'
	})
	.options('mb', {
		default: 12,
		alias: 'marker-black-diameter',
		describe: 'Diameter of the black portion of the selected colour marker (in pixels)'
	})
	.options('mm', {
		default: 9,
		alias: 'marker-mask-diameter',
		describe: 'Diameter of the mask (hidden) portion of the selected colour marker (in pixels)'
	})
	.argv;

/*
 * XML element constructors
 */

var svg = function(width, height, children) {
	return {tag: 'svg',
	        attr: {width:width, height:height, xmlns:'http://www.w3.org/2000/svg', version:'1.1'},
	        children: children};
};

var gradientStop = function(offset, colour, opacity) {
	return {tag: 'stop',
	        attr: {offset:offset, 'stop-color':colour, 'stop-opacity':opacity},
	        children: []};
};

var linearGradient = function(id, x1, y1, x2, y2, stops) {
	return {tag: 'linearGradient',
	        attr: {id:id, x1:x1, y1:y1, x2:x2, y2:y2},
	        children: stops};
};

var defs = function(definitions) {
	return {tag: 'defs',
	        attr: {},
	        children: definitions};
};

var rect = function(x, y, width, height, fill) {
	return {tag: 'rect',
	        attr: {x:x, y:y, width:width, height:height, fill:fill},
	        children: []};
};

var circle = function(cx, cy, r, fill) {
	return {tag: 'circle',
	        attr: {cx:cx, cy:cy, r:r, fill:fill},
	        children: []};
};

var line = function(x1, y1, x2, y2, stroke, transform) {
	return {tag: 'line',
	        attr: {x1:x1, y1:y1, x2:x2, y2:y2, stroke:stroke, transform:transform},
	        children: []};
};

var mask = function(id, x, y, width, height, children) {
	return {tag: 'mask',
	        attr: {id:id, x:x, y:y, width:width, height:height},
	        children: children};
};

var group = function(mask, children) {
	return {tag: 'g',
	        attr: {mask:mask},
	        children: children};
};

/*
 * XML conversion
 */

// very simple, very naïve XML pretty-printer... be careful about reusing this in other projects
// do not use with attributes that need to be escaped
var toXML = function(node) {
	var xml = '<' + node.tag;

	for(attribute in node.attr) {
		xml += ' ' + attribute + '="' + node.attr[attribute] + '"';
	}
	
	if (node.children.length == 0) {
		xml += '/>';
	}
	else {
		var indent = function(str) {
			return '\t' + str.replace('\n', '\n\t');
		};

		xml += '>\n' + indent(node.children.map(toXML).join('\n')) +
		       '\n</' + node.tag + '>';
	}

	return xml;
};

/*
 * HSL utilities
 */

var HSLToRGB = function(h, s, l) {
	var rgb;
	var chroma = (1 - Math.abs(2*l - 1)) * s;

	h /= 60; // convert from circlular to hexagonal representation, h represents side
	
	x = chroma * (1 - Math.abs(h%2 - 1)); // middle-sized rgb-component of colour

	     if (0 <= h && h < 1) rgb = [chroma, x, 0];
	else if (1 <= h && h < 2) rgb = [x, chroma, 0];
	else if (2 <= h && h < 3) rgb = [0, chroma, x];
	else if (3 <= h && h < 4) rgb = [0, x, chroma];
	else if (4 <= h && h < 5) rgb = [x, 0, chroma];
	else if (5 <= h && h < 6) rgb = [chroma, 0, x];

	m = l - chroma/2;

    return util.format('rgb(%d,%d,%d)', (rgb[0]+m) * 255, (rgb[1]+m) * 255, (rgb[2]+m) * 255);
}

/*
 * HSL wheel generation
 */

var clearance = 10, cl = clearance;

var markerX = clearance;
var markerY = clearance + argv.d + clearance + argv.s + clearance;
var markerSize = Math.max(argv.mm, argv.mb, argv.mw);
var markerCentreX = markerX + markerSize/2;
var markerCentreY = markerY + markerSize/2;

var imageWidth = clearance + Math.max(argv.s*2 + clearance, argv.d) + clearance; // bigger of either wheel or two squares alongside
var imageHeight = clearance + argv.s + clearance + argv.d + clearance + markerSize + clearance; // height of wheel and then height of square

var wheelRadius = argv.d / 2;

var wheelLineAngles = [];
for(var theta = 0; theta < 360; theta += 360 / argv.l) {
	wheelLineAngles.push(theta);
};

var rotate = function(angle, x, y) {
	return util.format('rotate(%d,%d,%d)', angle, x, y);	
};

var wheelLine = function(angle) {
	return line(clearance + wheelRadius, 0, clearance + wheelRadius, clearance + wheelRadius,
	            HSLToRGB(angle, 1, 0.5), rotate(angle, clearance + wheelRadius, clearance + wheelRadius));
};

var document =
	svg(imageWidth, imageHeight, [
		defs([
			linearGradient('lightness', '0%', '0%', '0%', '100%', [
				gradientStop('0%', HSLToRGB(0,0,1), 1),
				gradientStop('50%', HSLToRGB(0,0,1), 0),
				gradientStop('50%', HSLToRGB(0,0,0), 0),
				gradientStop('100%', HSLToRGB(0,0,0), 1)
			]),
			linearGradient('saturation', '0%', '0%', '100%', '0%', [
				gradientStop('0%', HSLToRGB(0,0,0.5), 0),
				gradientStop('100%', HSLToRGB(0,0,0.5), 1)
			])
		]),
		rect(clearance, clearance + argv.d + clearance, argv.s, argv.s, 'url(#saturation)'),
		rect(clearance, clearance + argv.d + clearance, argv.s, argv.s, 'url(#lightness)'),
		rect(clearance + argv.s + clearance, clearance + argv.d + clearance, argv.s, argv.s, 'white'),
		mask('wheel', clearance, clearance, argv.d, argv.d, [
			circle(clearance + wheelRadius, clearance + wheelRadius, wheelRadius, 'white'),
			circle(clearance + wheelRadius, clearance + wheelRadius, wheelRadius - argv.w, 'black')
		]),
		group('url(#wheel)', wheelLineAngles.map(wheelLine)),
		mask('marker', markerX, markerY, markerSize, markerSize, [
			circle(markerCentreX, markerCentreY, markerSize, 'white'),
			circle(markerCentreX, markerCentreY, argv.mm/2, 'black')
		]),
		group('url(#marker)', [
			circle(markerCentreX, markerCentreY, argv.mw/2, 'white'),
			circle(markerCentreX, markerCentreY, argv.mb/2, 'black')
		])
	]);

process.stdout.write(toXML(document));
