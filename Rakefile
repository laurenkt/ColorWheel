require 'rubygems'
require 'bundler/setup'

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
	sh "bundle exec coffee -j cw-colorwheel.js -c %s" % files.join(' ')
end

file 'cw-colorwheel.min.js' => ['cw-colorwheel.js'] do
	sh "bundle exec closure --js cw-colorwheel.js --js_output_file cw-colorwheel.min.js"
end

desc "Compile JS output from CoffeeScript"
task :build => ['cw-colorwheel.js']

desc "Minify JS output"
task :minify => ['cw-colorwheel.min.js']

task :default => ['build']

task :test do
	sh "bundle exec jasmine-headless-webkit -j spec/support/jasmine.yml -c"
end

task :all => ['build', 'test', 'minify']