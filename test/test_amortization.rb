require 'rubygems'
require 'finance'
require 'flt/d'
require 'test/unit'

class TestBasicAmortization < Test::Unit::TestCase
	def setup
		@rate = Rate.new(0.0375, :apr, :duration => 30.years)
    @principal = D(200000)
		@amortization = Amortization.new(@principal, @rate)
	end

  def test_balance
		assert_equal D(0), @amortization.balance
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
		0.upto 10 do |adj|
			@rates << Rate.new(0.0375 + (D('0.01') * adj), :apr, :duration => 3.years)
		end
    @principal = D(200000)
		@amortization = Amortization.new(@principal, *@rates)
  end

  def test_balance
		assert_equal D(0), @amortization.balance
	end

	def test_principal
		assert_equal @principal, @amortization.principal
	end

  def test_sum
    assert_equal D(0), @amortization.payments.sum + @amortization.interest.sum + @amortization.principal
  end
end
