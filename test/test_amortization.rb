require 'rubygems'
require 'finance'
require 'flt/d'
require 'test/unit'

class TestBasicAmortization < Test::Unit::TestCase
  def interest_in_period(principal, rate, payment, period)
    -(-rate*principal*(1+rate)**(period-1) - payment*((1+rate)**(period-1)-1)).round(2)
  end

  def setup
    @rate = Rate.new(0.0375, :apr, :duration => 30.years)
    @principal = D(200000)
    @amortization = Amortization.new(@principal, @rate)
  end

  def test_balance
    assert @amortization.balance.zero?
  end

  def test_duration
    assert_equal 360, @amortization.duration
  end

  def test_interest
    0.upto 359 do |period|
      assert_equal @amortization.interest[period], interest_in_period(@principal, @rate.monthly, @amortization.payment, period+1)
    end
  end

  def test_interest_sum
    assert_equal D('133443.53'), @amortization.interest.sum
  end

  def test_payment
    assert_equal D('-926.23'), @amortization.payment
  end

  def test_payments
    payments = [ D('-926.23') ] * @rate.duration
    # Account for rounding errors in last payment.
    payments[-1] = D('-926.96')
    assert_equal payments, @amortization.payments
  end

  def test_payments_sum
    assert_equal D('-333443.53'), @amortization.payments.sum
  end

  def test_principal
    assert_equal @principal, @amortization.principal
  end

  def test_sum
    assert_equal D(0), @amortization.payments.sum + @amortization.interest.sum + @amortization.principal
  end
end

class TestAdjustableAmortization < Test::Unit::TestCase
  def setup
    @rates = []
    0.upto 9 do |adj|
      @rates << Rate.new(0.0375 + (D('0.01') * adj), :apr, :duration => 3.years)
    end
    @principal = D(200000)
    @amortization = Amortization.new(@principal, *@rates)
  end

  def test_balance
    assert @amortization.balance.zero?
  end

  def test_duration
    assert_equal 360, @amortization.duration
  end

  def test_interest_sum
    assert_equal D('277505.92'), @amortization.interest.sum
  end

  def test_payment
    assert_nil @amortization.payment
  end

  def test_payments
    values = %w{926.23 1033.73 1137.32 1235.39 1326.30 1408.27 1479.28 1537.03 1578.84 1601.66 1601.78}
    values.collect!{ |v| -D(v) }
    
    payments = []
    values[0,9].each do |v|
      36.times do
        payments << v
      end
    end

    35.times { payments << values[9] }
    payments << values[10]

    payments.each_with_index do |payment, index|
      assert_equal payment, @amortization.payments[index]
    end
  end

  def test_payment_sum
    assert_equal D('-477505.92'), @amortization.payments.sum
  end

  def test_principal
    assert_equal @principal, @amortization.principal
  end

  def test_sum
    assert_equal D(0), @amortization.payments.sum + @amortization.interest.sum + @amortization.principal
  end
end

class TestExtraPaymentAmortization < Test::Unit::TestCase
  def setup
    @rate = Rate.new(0.0375, :apr, :duration => 30.years)
    @principal = D(200000)
    @amortization = Amortization.new(@principal, @rate){ |period| period.payment - 100 }
  end

  def test_additional_payments_sum
    assert_equal D('-30084.86'), @amortization.additional_payments.sum
  end
  
  def test_balance
    assert @amortization.balance.zero?
  end

  def test_duration
    assert_equal 301, @amortization.duration
  end

  def test_interest_sum
    assert_equal D('108880.09'), @amortization.interest.sum
  end

  def test_payment
    assert_equal D('-1026.23'), @amortization.payment
  end

  def test_payment_sum
    assert_equal D('-308880.09'), @amortization.payments.sum
  end

  def test_principal
    assert_equal @principal, @amortization.principal
  end

  def test_sum
    assert_equal D(0), @amortization.payments.sum + @amortization.interest.sum + @amortization.principal
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
