require 'rubygems'
require 'flt'
require 'rates'
require 'test/unit'

class TestEffectiveRates < Test::Unit::TestCase
	def setup
		@rate = Rate.new( :effective => '0.0375' )
	end

	def test_effective_to_nominal
		assert_equal Flt::DecNum('0.03687'), @rate.nominal.round(5)
	end
end
