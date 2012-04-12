require 'rubygems'
require 'bundler/setup'

files = FileList[
	"src/noconflict.coffee",
	"src/helpers.coffee",
	"src/color.coffee",
	"src/wheel.coffee",
	"src/jquery.coffee"
]

# Tasks

task :all => [:default, :test, :minify]

desc "Compile JS output from CoffeeScript"
task :default => 'cw-colorwheel.js'

desc "Minify output"
task :minify => ['cw-colorwheel.min.js', 'cw-style.min.css']

desc "Run Jasmine tests"
task :test => :default do
	puts "* Running tests"
	sh "jasmine-headless-webkit -cj spec/support/jasmine.yml"
	puts "* Done"
end

CLEAN = FileList["*.js", "*.min.css"]
desc "Remove generated output files"
task :clean do
	if CLEAN.length > 0
		puts "* Cleaning output files"
		sh "rm %s" % CLEAN.join(' ')
		puts "* Done"
	else
		puts "* Already clean"
	end
end

# Compilation rules

file 'cw-colorwheel.js' => files do |t|
	puts "* Compiling CoffeeScript"
	sh "bundle exec coffee -j cw-colorwheel.js -c %s" % files.join(' ')
	puts "* Done (#{t.name})"
end

# Minify rules

file 'cw-colorwheel.min.js' => 'cw-colorwheel.js' do |t|
	puts "* Compressing Javascript"
	sh "bundle exec closure --js #{t.prerequisites[0]} --js_output_file #{t.name}"
	puts "* Done (#{t.name})"
end

file 'cw-style.min.css' => 'cw-style.css' do |t|
	puts "* Compressing CSS"
	require 'yuicompressor'
	compressed = YUICompressor.compress_css(IO.read(t.prerequisites[0]))
	File.open(t.name, 'w') { |f| f.write(compressed) }
	puts "* Done (#{t.name})"
end