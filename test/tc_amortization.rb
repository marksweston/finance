require 'rubygems'
require 'amortization'
require 'flt/d'
require 'rates'
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

	def test_payment
		assert_equal D('-926.23'), @amortization.payment
	end

	def test_payments
		assert_equal [ D('-926.23') ] * @rate.duration, @amortization.payments
	end

	def test_principal
		assert_equal D(200000), @amortization.principal
	end
end
