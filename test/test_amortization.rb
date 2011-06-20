require 'rubygems'
require 'finance'
require 'flt/d'
require 'test/unit'

class TestBasicAmortization < Test::Unit::TestCase
	def setup
		@rate = Rate.new :effective => 0.0375
		@rate.duration = 360
		@amortization = Amortization.new(D(200000), @rate)
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
		assert_equal D(200000), @amortization.principal
	end
end
