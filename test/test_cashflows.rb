require_relative 'test_helper'

describe "Cashflows" do
  describe "an array of numeric cashflows" do
    it "should have an Internal Rate of Return" do
      assert_equal D("0.143"), Calculator::Irr.new([-4000,1200,1410,1875,1050]).compute.round(3)
      assert_raises(ArgumentError) { Calculator::Irr.new([10,20,30]).compute }
    end

    it "should have a Net Present Value" do
      assert_equal D("49.211"), Calculator::Npv.new([-100.0, 60, 60, 60], 0.1).compute.round(3)
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
      assert_equal D("0.024851"), Calculator::Xirr.new(@xactions).compute.effective.round(6)
      assert_raises(ArgumentError) { Calculator::Xirr.new(@xactions[1, 2]).compute }
    end

    it "should have a Net Present Value" do
      assert_equal D("-937.41"), Calculator::Xnpv.new(@xactions, 0.6).compute.round(2)
    end
  end
end
