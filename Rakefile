require 'rake/clean'

files = [
	"src/noconflict.coffee",
	"src/helpers.coffee",
	"src/color.coffee",
	"src/wheel.coffee",
	"src/jquery.coffee"
]

CLOBBER.include('*.js')

file 'cw-colorwheel.js' => files do
	sh "coffee -j cw-colorwheel.js -c %s" % files.join(' ')
end

file 'cw-colorwheel.min.js' => ['cw-colorwheel.js'] do
	sh "closure --js cw-colorwheel.js --js_output_file cw-colorwheel.min.js"
end

desc "Compile JS output from CoffeeScript"
task :build => ['cw-colorwheel.js']

desc "Minify JS output"
task :minify => ['cw-colorwheel.min.js']

task :default => ['build']