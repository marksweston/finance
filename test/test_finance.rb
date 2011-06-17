require 'finance'
require 'test/unit'

class TestPMT < Test::Unit::TestCase
	def test_simple
		assert_in_delta(926.231, Finance.pmt(200000, 0.0375/12, 360), 0.001)
	end
end
