require 'rubygems'
require 'rake'

SPEC = Gem::Specification.new do |s|
	s.name = "finance"
	s.version = "0.0.1"
	s.author = "Bill Kranec"
	s.email = "wkranec@gmail.com"
	s.platform = Gem::Platform::RUBY
	s.summary = "Ruby implementations of common financial formulas."
	s.description = "The goal of the finance library is to provide Ruby implementations of common financial formulas, with a function syntax similar to most modern spreadsheet programs."

	s.homepage = "http://finance.rubyforge.org"
	s.rubyforge_project = "finance"

	s.files = FileList['lib/finance.rb'].to_a

	s.has_rdoc = true
	s.extra_rdoc_files = ["README"]
end
