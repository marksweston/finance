require_relative 'test_helper'

# @see http://tinyurl.com/6zroqvd for detailed calculations for the
#   examples in these unit tests.
describe "Amortization" do
  def ipmt(principal, rate, payment, period)
    -(-rate*principal*(1+rate)**(period-1) - payment*((1+rate)**(period-1)-1)).round(2)
  end

  describe "amortization with a 0% rate" do
    it "should not raise a divide-by-zero error" do
      rate = Rate.new(0, :apr, :duration => 30 * 12)
      Amortization.new(D(10000), rate) # should not raise an error
    end
  end

  describe "a fixed-rate amortization of 200000 at 3.75% over 30 years" do
    before(:all) do
      @rate = Rate.new(0.0375, :apr, :duration => (30 * 12))
      @principal = D(200000)
      @std = Amortization.new(@principal, @rate)
    end

    it "should have a principal of $200,000" do
      assert_equal @principal, @std.principal
    end

    it "should have a final balance of zero" do
      assert @std.balance.zero?
    end

    it "should have a duration of 360 months" do
      assert_equal 360, @std.duration
    end

    it "should have a monthly payment of $926.23" do
      assert_equal D('-926.23'), @std.payment
    end

    it "should have a final payment of $926.96 (due to rounding)" do
      assert_equal D('-926.96'), @std.payments[-1]
    end

    it "should have total payments of $333,443.53" do
      assert_equal D('-333443.53'), @std.payments.sum
    end

    it "should have interest charges which agree with the standard formula" do
      0.upto 359 do |period|
        assert_equal @std.interest[period], ipmt(@principal, @rate.monthly, @std.payment, period+1)
      end
    end

    it "should have total interest charges of $133,433.33" do
      assert_equal D('133443.53'), @std.interest.sum
    end
  end

  describe "an adjustable rate amortization of 200000 starting at 3.75% and increasing by 1% every 3 years" do
    before(:all) do
      @rates = []
      0.upto 9 do |adj|
        @rates << Rate.new(0.0375 + (D('0.01') * adj), :apr, :duration => (3 * 12))
      end
      @principal = D(200000)
      @arm = Amortization.new(@principal, *@rates)
    end

    it "should have a principal of $200,000" do
      assert_equal @principal, @arm.principal
    end

    it "should have a final balance of zero" do
      assert @arm.balance.zero?
    end

    it "should have a duration of 360 months" do
      assert_equal 360, @arm.duration
    end

    it "should not have a fixed monthly payment (since it changes)" do
      assert_nil @arm.payment
    end

    it "should have payments which increase every three years" do
      values = %w{926.23 1033.73 1137.32 1235.39 1326.30 1408.27 1479.28 1537.03 1578.84 1601.66 }
      values.collect!{ |v| -D(v) }

      payments = []
      values[0,9].each do |v|
        36.times do
          payments << v
        end
      end

      35.times { payments << values[9] }

      payments[0..-2].each_with_index do |payment, index|
        assert_equal payment, @arm.payments[index]
      end
    end

    it "should have a final payment of $1601.78 (due to rounding)" do
      assert_equal D('-1601.78'), @arm.payments[-1]
    end

    it "should have total payments of $47,505.92" do
      assert_equal D('-477505.92'), @arm.payments.sum
    end

    it "should have total interest charges of $277,505.92" do
      assert_equal D('277505.92'), @arm.interest.sum
    end
  end

  describe "a fixed-rate amortization of 200000 at 3.75% over 30 years, where an additional 100 is paid each month" do
    before(:all) do
      @rate = Rate.new(0.0375, :apr, :duration => (30 * 12))
      @principal = D(200000)
      @exp = Amortization.new(@principal, @rate){ |period| period.payment - 100 }
    end

    it "should have a principal of $200,000" do
      assert_equal @principal, @exp.principal
    end

    it "should have a final balance of zero" do
      assert @exp.balance.zero?
    end

    it "should have a duration of 301 months" do
      assert_equal 301, @exp.duration
    end

    it "should have a monthly payment of $1026.23" do
      assert_equal D('-1026.23'), @exp.payment
    end

    it "should have a final payment of $1011.09" do
      assert_equal D('-1011.09'), @exp.payments[-1]
    end

    it "should have total payments of $308,880.09" do
      assert_equal D('-308880.09'), @exp.payments.sum
    end

    it "should have total additional payments of $30,084.86" do
      assert_equal D('-30084.86'), @exp.additional_payments.sum
    end

    it "should have total interest charges of $108880.09" do
      assert_equal D('108880.09'), @exp.interest.sum
    end
  end
end

describe "Numeric Method" do
  it 'works with simple invocation' do
    rate = Rate.new(0.0375, :apr, :duration => (30 * 12))
    amt_method = 300000.amortize(rate)
    amt_class  = Amortization.new(300000, rate)
    assert_equal amt_method, amt_class
  end

  it 'works with block invocation' do
    rate = Rate.new(0.0375, :apr, :duration => (30 * 12))
    amt_method = 300000.amortize(rate){ |period| period.payment-300 }
    amt_class  = Amortization.new(300000, rate){ |period| period.payment-300 }
    assert_equal amt_method, amt_class
  end
end
