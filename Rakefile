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

task :jasmine => ['build'] do
	require 'jasmine'
	require 'spec/support/jasmine_config.rb'
	
	puts "your tests are at http://localhost:8888/:"
	Jasmine::Config.new.start_server(8888)
end

require 'jasmine-headless-webkit'
Jasmine::Headless::Task.new('jasmine:headless') do |t|
	t.colors = true
	t.keep_on_error = true
	t.jasmine_config = 'spec/support/jasmine.yml'
end
