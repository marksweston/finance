require 'rubygems'

SPEC = Gem::Specification.new do |s|
  s.name = "finance"
  s.version = "2.0.0"
  s.author = "Bill Kranec"
  s.email = "wkranec@gmail.com"
  s.platform = Gem::Platform::RUBY
  s.summary = "a library for financial modelling in Ruby."
  s.description = "The finance library provides a Ruby interface for working with interest rates, mortgage amortization, and cashflows (NPV, IRR, etc.)."
  s.homepage = "https://rubygems.org/gems/finance"

  s.required_ruby_version = '>=1.9'
  s.add_dependency 'flt', '>=1.3.0'
  s.add_development_dependency 'minitest', '>= 4.7.5'
  s.add_development_dependency 'activesupport', '>= 4.0.0'
  s.files = ['README.md', 'COPYING', 'COPYING.LESSER', 'HISTORY', Dir.glob('lib/**/*.rb'), Dir.glob('test/**/*.rb')].flatten
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md', 'COPYING', 'COPYING.LESSER', 'HISTORY']
end
