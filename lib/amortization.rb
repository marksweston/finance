require 'cashflows'

class Amortization
	attr_accessor :balance
	attr_accessor :rate
	attr_accessor :payment
	attr_accessor :payments
	attr_accessor :periods
	attr_accessor :principal

	def compute(balance, rate)
		@payment = Amortization.payment balance, rate.monthly, rate.duration

		rate.duration.times do
			@payments << @payment
			@balance += (@balance * rate.monthly.round(6)).round(2) + @payment
		end
	end

	def initialize(principal, rate)
		@principal = principal
		@balance   = principal
		@rate      = rate
		@payments  = []

		compute(@balance, @rate)
	end

	def Amortization.payment(balance, rate, periods)
		-(balance * (rate + (rate / ((1 + rate) ** periods - 1)))).round(2)
	end
end
