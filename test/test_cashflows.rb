require_relative '../lib/finance/cashflows.rb'
require_relative '../lib/finance/rates.rb'
require_relative '../lib/finance/transaction.rb'
include Finance

require 'flt/d'
require 'minitest/unit'
require 'shoulda'

class TestCashflows < Test::Unit::TestCase
  context "an array of numeric cashflows" do
    should "have an Internal Rate of Return" do
      assert_equal D("0.143"), [-4000,1200,1410,1875,1050].irr.round(3)
      assert_raises(ArgumentError) { [10,20,30].irr }
    end

    should "have a Net Present Value" do
      assert_equal D("49.211"), [-100.0, 60, 60, 60].npv(0.1).round(3)
    end
  end
  context "an array of Transactions" do
    setup do
      @xactions=[]
      @xactions << Transaction.new(-1000, :date => Time.new(1985,01,01))
      @xactions << Transaction.new(  600, :date => Time.new(1990,01,01))
      @xactions << Transaction.new(  600, :date => Time.new(1995,01,01))
    end

    should "have an Internal Rate of Return" do
      assert_equal D("0.024851"), @xactions.xirr.effective.round(6)
      assert_raises(ArgumentError) { @xactions[1,2].xirr }
    end

    should "have a Net Present Value" do
      assert_equal D("-937.41"), @xactions.xnpv(0.6).round(2)
    end
  end
end
