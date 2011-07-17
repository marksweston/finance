require_relative '../lib/finance/cashflows.rb'

require 'flt/d'
require 'minitest/unit'
require 'shoulda'

class TestCashflows < Test::Unit::TestCase
  context "an array of cashflows" do
    should "have an Internal Rate of Return" do
      assert_equal D("0.143"), [-4000,1200,1410,1875,1050].irr.round(3)
    end
    should "have a Net Present Value" do
      assert_equal D("49.211"), [-100.0, 60, 60, 60].npv(0.1).round(3)
    end
  end
end
