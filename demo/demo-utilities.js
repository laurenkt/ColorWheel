var round = function(n) {
	return Math.round(n * 100) / 100;
}

var rgb = function(rgb) {
	return 'rgb(<strong style="color:red">' +round(rgb.r)+ '</strong>,<strong style="color:green">' +round(rgb.g)+ '</strong>,<strong style="color:blue">' +round(rgb.b)+ '</strong>)'; 
}

var hsl = function(hsl) {
	return 'hsl(<strong style="color:' +cw.HSLToString({h:hsl.h})+ '">' +round(hsl.h)+ '</strong>,<strong>' +round(hsl.s)+ '</strong>,<strong>' +round(hsl.l)+ '</strong>)';
}

var summarize = function(color) {
	return '<strong>' + cw.HSLToString(color) + '</strong>\n' + rgb(cw.HSLToRGB(color)) + '\n' + hsl(color);
}
