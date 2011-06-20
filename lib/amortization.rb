require 'cashflows'

class Period
	attr_accessor :payment
	attr_accessor :principal
	attr_accessor :rate

	# Return the remaining balance at the end of the period.
	def balance
		@principal + @payment + self.interest
	end

	def initialize(principal, rate, payment)
		@principal = principal
		@rate = rate
		@payment = payment
	end

	# Return the interest charged for the period.
	def interest
		(@principal * @rate).round(2)
	end
end

class Amortization
	attr_accessor :balance
	attr_accessor :duration
	attr_accessor :payment
	attr_accessor :periods
	attr_accessor :principal
	attr_accessor :rate

	def compute(balance, rate)
		duration = @duration - @periods.length
		@payment = Amortization.payment balance, rate.monthly, duration

		rate.duration.times do
			if @payment > @balance
				@payment = @balance
			end

			period = Period.new(@balance, rate.monthly, @payment)
			@periods << period
			@balance = period.balance

			if @balance.zero?
				break
			end
		end
	end

	def initialize(principal, rate)
		@principal = principal
		@balance   = principal
		@rate      = rate
		@duration  = rate.duration
		@periods   = []

		compute(@balance, @rate)

		# Add any remaining balance due to rounding error to the last payment.
		unless @balance.zero?
			@periods[-1].payment -= @balance
			@balance = 0
		end
	end

	def interest
		@periods.collect { |period| period.interest }
	end

  # Return the periodic payment due on a loan, based on the
  #{http://en.wikipedia.org/wiki/Amortization_calculator amortization process}.
	def Amortization.payment(balance, rate, periods)
		-(balance * (rate + (rate / ((1 + rate) ** periods - 1)))).round(2)
	end

	def payments
		@periods.collect { |period| period.payment }
	end
end

class Numeric
	def amortize(rate)
		Amortization.new(self, rate)
	end
end
