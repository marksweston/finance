require 'rubygems'
require 'finance'
require 'flt/d'
require 'test/unit'

class TestRates < Test::Unit::TestCase
	def test_apr
		rate = Rate.new :apr => 0.0375
		assert_equal D('0.03687'), rate.nominal.round(5)
	end

	def test_duration
		rate = Rate.new :effective => 0.0375, :duration => 30.years
		assert_equal 360, rate.duration
	end
		
	def test_effective
		rate = Rate.new :nominal => 0.03687
		assert_equal D('0.0375'), rate.effective.round(4)
	end

	def test_monthly
		rate = Rate.new :effective => 0.0375
		assert_equal D('0.003125'), rate.monthly
	end

	def test_nominal
		rate = Rate.new :effective => 0.0375
		assert_equal D('0.03687'), rate.nominal.round(5)
	end
end
