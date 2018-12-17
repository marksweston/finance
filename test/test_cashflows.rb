require_relative 'test_helper'

describe "Cashflows" do
  describe "an array of numeric cashflows" do
    it "should have an Internal Rate of Return" do
      assert_equal D("0.143"), [-4000,1200,1410,1875,1050].irr.round(3)
      assert_raises(ArgumentError) { [10,20,30].irr }
    end

    it "should have a Net Present Value" do
      assert_equal D("49.211"), [-100.0, 60, 60, 60].npv(0.1).round(3)
    end
  end

  describe "an array of Transactions" do
    before(:all) do
      @xactions=[]
      @xactions << Transaction.new(-1000, :date => Time.new(1985, 1, 1))
      @xactions << Transaction.new(  600, :date => Time.new(1990, 1, 1))
      @xactions << Transaction.new(  600, :date => Time.new(1995, 1, 1))
    end

    it "should have an Internal Rate of Return" do
      assert_equal D("0.024851"), @xactions.xirr.effective.round(6)
      assert_raises(ArgumentError) { @xactions[1, 2].xirr }
    end

    it "should have a Net Present Value" do
      assert_equal D("-937.41"), @xactions.xnpv(0.6).round(2)
    end

    it "should properly calculate IRR when Complex numbers arise from calculations" do
      # Note that times must be in UTC (+00:00) here, so
      # the local system's DST settings don't screw us up.
      arr = [ Finance::Transaction.new( 70, :date => Time.new(2015, 7, 31, 0, 0, 0, '+00:00')),
              Finance::Transaction.new(-90, :date => Time.new(2021, 1, 13, 0, 0, 0, '+00:00')),
              Finance::Transaction.new(-20, :date => Time.new(2021, 3, 31, 0, 0, 0, '+00:00')) ]
      assert_equal D("0.085677"), arr.xirr.effective.round(6)
    end

    it "IRR should decrease as payback moves further and further into the future" do
      prev_max = 99999

      (1..30).each do |n|
        arr = [ Finance::Transaction.new(100, :date => Time.new(2001, 1, 1, 0, 0, 0, '+00:00')),
                Finance::Transaction.new(-50, :date => Time.new(2001, 2, 1, 0, 0, 0, '+00:00')),
                Finance::Transaction.new(-60, :date => Time.new(2001, 2, 1, 0, 0, 0, '+00:00') + (n * 30*24*3600)) ]

        irr = arr.xirr.effective.round(6)

        assert(irr > 0, "IRR should not be negative; encountered #{irr}")
        assert(irr < prev_max, "IRR should only decrease, but it increased from #{prev_max} to #{irr}")

        prev_max = irr
      end
    end

  end
end
