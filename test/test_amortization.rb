require 'finance'
require 'flt/d'
require 'shoulda'
require 'test/unit'

# @see http://tinyurl.com/6zroqvd for detailed calculations for the
# examples in these unit tests.
class TestAmortization < Test::Unit::TestCase
  def ipmt(principal, rate, payment, period)
    -(-rate*principal*(1+rate)**(period-1) - payment*((1+rate)**(period-1)-1)).round(2)
  end

  context "a fixed-rate amortization of 200000 at 3.75% over 30 years" do
    setup do
      @rate = Rate.new(0.0375, :apr, :duration => 30.years)
      @principal = D(200000)
      @std = Amortization.new(@principal, @rate)
    end

    should "have a principal of $200,000" do
      assert_equal @principal, @std.principal
    end

    should "have a final balance of zero" do
      assert @std.balance.zero?
    end

    should "have a duration of 360 months" do
      assert_equal 360, @std.duration
    end

    should "have a monthly payment of $926.23" do
      assert_equal D('-926.23'), @std.payment
    end

    should "have a final payment of $926.96 (due to rounding)" do
      assert_equal D('-926.96'), @std.payments[-1]
    end

    should "have total payments of $333,443.53" do
      assert_equal D('-333443.53'), @std.payments.sum
    end

    should "have interest charges which agree with the standard formula" do
      0.upto 359 do |period|
        assert_equal @std.interest[period], ipmt(@principal, @rate.monthly, @std.payment, period+1)
      end
    end

    should "have total interest charges of $133,433.33" do
      assert_equal D('133443.53'), @std.interest.sum
    end
  end

  context "an adjustable rate amortization of 200000 starting at 3.75% and increasing by 1% every 3 years" do
    setup do
      @rates = []
      0.upto 9 do |adj|
        @rates << Rate.new(0.0375 + (D('0.01') * adj), :apr, :duration => 3.years)
      end
      @principal = D(200000)
      @arm = Amortization.new(@principal, *@rates)
    end

    should "have a principal of $200,000" do
      assert_equal @principal, @arm.principal
    end

    should "have a final balance of zero" do
      assert @arm.balance.zero?
    end

    should "have a duration of 360 months" do
      assert_equal 360, @arm.duration
    end

    should "not have a fixed monthly payment (since it changes)" do
      assert_nil @arm.payment
    end

    should "have payments which increase every three years" do
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

    should "have a final payment of $1601.78 (due to rounding)" do
      assert_equal D('-1601.78'), @arm.payments[-1]
    end

    should "have total payments of $47,505.92" do
      assert_equal D('-477505.92'), @arm.payments.sum
    end

    should "have total interest charges of $277,505.92" do
      assert_equal D('277505.92'), @arm.interest.sum
    end
  end

  context "a fixed-rate amortization of 200000 at 3.75% over 30 years, where an additional 100 is paid each month" do
    setup do
      @rate = Rate.new(0.0375, :apr, :duration => 30.years)
      @principal = D(200000)
      @exp = Amortization.new(@principal, @rate){ |period| period.payment - 100 }
    end

    should "have a principal of $200,000" do
      assert_equal @principal, @exp.principal
    end

    should "have a final balance of zero" do
      assert @exp.balance.zero?
    end

    should "have a duration of 301 months" do
      assert_equal 301, @exp.duration
    end

    should "have a monthly payment of $1026.23" do
      assert_equal D('-1026.23'), @exp.payment
    end

    should "have a final payment of $1011.09" do
      assert_equal D('-1011.09'), @exp.payments[-1]
    end

    should "have total payments of $308,880.09" do
      assert_equal D('-308880.09'), @exp.payments.sum
    end

    should "have total additional payments of $30,084.86" do
      assert_equal D('-30084.86'), @exp.additional_payments.sum
    end

    should "have total interest charges of $108880.09" do
      assert_equal D('108880.09'), @exp.interest.sum
    end
  end
end

class TestNumericMethod < Test::Unit::TestCase
  def test_simple
    rate = Rate.new(0.0375, :apr, :duration => 30.years)
    amt_method = 300000.amortize(rate)
    amt_class  = Amortization.new(300000, rate)
    assert_equal amt_method, amt_class
  end

  def test_with_block
    rate = Rate.new(0.0375, :apr, :duration => 30.years)
    amt_method = 300000.amortize(rate){ |period| period.payment-300 }
    amt_class  = Amortization.new(300000, rate){ |period| period.payment-300 }
    assert_equal amt_method, amt_class
  end
end
