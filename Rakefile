require 'rake'
require 'rake/testtask'

task :default => [:test_units]

Rake::TestTask.new("test_units") do |t|
	t.pattern = 'test/*.rb'
	t.verbose = true
	t.warning = true
end
