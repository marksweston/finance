class Amortization
	attr_accessor :balance
	attr_accessor :rate
	attr_accessor :payment
	attr_accessor :periods
	attr_accessor :principal

	def compute(balance, rate)
		@payment = balance * (rate + (rate / ((1 + rate) ** rate.duration - 1)))
	end

	def initialize(principal, rate)
		@principal = principal
		@balance   = principal
		@rate      = rate
	end
end
