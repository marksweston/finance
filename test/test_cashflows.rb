require 'finance'
require 'test/unit'

class TestIRR < Test::Unit::TestCase
  def test_simple
    assert_in_delta(0.143, [-4000,1200,1410,1875,1050].irr, 0.001)
  end
end

class TestNPV < Test::Unit::TestCase
  def test_simple
    assert_in_delta(49.211, [-100.0, 60, 60, 60].npv(0.1), 0.001)
  end
end
