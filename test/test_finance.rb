require 'finance'
require 'test/unit'

class TestIRR < Test::Unit::TestCase
	def test_simple
		assert_in_delta(0.143, Finance.irr([-4000,1200,1410,1875,1050]), 0.001)
	end
end

class TestPMT < Test::Unit::TestCase
	def test_simple
		assert_in_delta(926.231, Finance.pmt(200000, 0.0375/12, 360), 0.001)
	end
end

class TestNPV < Test::Unit::TestCase
	def test_simple
		assert_in_delta(49.211, Finance.npv(0.1, [-100.0, 60, 60, 60]), 0.001)
	end
end
