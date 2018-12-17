SPEC = Gem::Specification.new do |s|
  s.name = "finance"
  s.version = "2.0.1"
  s.author = "Bill Kranec"
  s.license = "LGPL-3.0"
  s.email = "wkranec@gmail.com"
  s.platform = Gem::Platform::RUBY
  s.summary = "a library for financial modelling in Ruby."
  s.description = "The finance library provides a Ruby interface for working with interest rates, mortgage amortization, and cashflows (NPV, IRR, etc.)."
  s.homepage = "https://rubygems.org/gems/finance"

  s.required_ruby_version = '>=1.9'
  s.add_dependency 'flt', '>=1.3.0'
  s.add_development_dependency 'minitest', '>= 4.7.5'
  s.add_development_dependency 'activesupport', '>= 4.0.0'
  s.add_development_dependency 'pry'
  s.files = `git ls-files`.split("\n")
end
