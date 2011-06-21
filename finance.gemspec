require 'rubygems'
require 'rake'

SPEC = Gem::Specification.new do |s|
	s.name = "finance"
	s.version = "0.1.1"
	s.author = "Bill Kranec"
	s.email = "wkranec@gmail.com"
	s.platform = Gem::Platform::RUBY
	s.summary = "a library for financial calculations in Ruby."
	s.description = "The finance library provides a Ruby interface for working with interest rates, mortgage amortization, and cashflows (NPV, IRR, etc.)."
	s.homepage = "https://rubygems.org/gems/finance"

	s.add_dependency 'flt', '>=1.3.0'
	s.files = FileList['README', 'COPYING', 'COPYING.LESSER', 'lib/**/*.rb', 'test/**/*.rb'].to_a

	s.has_rdoc = true
	s.extra_rdoc_files = ["README"]
end
