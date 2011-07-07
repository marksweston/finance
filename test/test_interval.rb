require 'finance'
require 'test/unit'

class TestTime < Test::Unit::TestCase
  def test_months
    assert_equal 360, 360.months
  end

  def test_years
    assert_equal 360, 30.years
  end
end
