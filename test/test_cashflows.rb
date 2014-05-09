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
  end

  describe "guess " do
    before(:all) do
      @transactions = []
      @transactions << Transaction.new(-1000, date: Time.new(1957,1,1))
      @transactions << Transaction.new(390000, date: Time.new(2013,1,1))
    end

    it "should fail to calculate with default guess (1.0)" do
      assert_equal D('-9999999999998.948'), @transactions.xirr.apr
    end

    it 'should calculate correct rate with new guess (0.1)' do
      assert_equal D('0.112340'), @transactions.xirr(0.1).apr.round(6)
    end

    it 'should not allow non-numeric guesses' do
      assert_raises(ArgumentError) { @transactions.xirr("error")}
    end

  end

end
