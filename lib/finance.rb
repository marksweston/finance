# The *Finance* module adheres to the following conventions for
# financial calculations:
#
#  * Positive values represent cash inflows (money received); negative
#    values represent cash outflows (payments).
#  * *principal* represents the outstanding balance of a loan or annuity.
#  * *rate* represents the interest rate _per period_.
module Finance

	# Return the internal rate of return for a given sequence of cashflows.
	#
	# References:
	#  * http://en.wikipedia.org/wiki/Internal_rate_of_return
	def Finance.irr(cashflows, iterations=100)
		rate = 1.0
		investment = cashflows[0]
		for i in 1..iterations+1
			rate = rate * (1 - npv(rate, cashflows) / investment)
		end
		rate
	end

	def Finance.payments(principal, rates)
		p_total = rates.inject(0) { |sum, n| sum + n[0] }
		p_current = 0
		payments = []

		rates.each do |periods, rate|
			payment = Finance.pmt(principal, rate, p_total-p_current)

			begin
				payment = payment.round(2)
			rescue ArgumentError
				payment = (payment * 100.0).round / 100.0
			end

			if block_given?
				payment = yield(payment)
			end

			periods.times do
				interest = principal * rate

				if payment > principal + interest
					payment = principal + interest
				end

				principal = principal + interest - payment

				begin
					principal = principal.round(2)
				rescue ArgumentError
					principal = (principal * 100.0).round / 100.0
				end

				payments << payment
				break if principal == 0
				
				p_current = p_current + 1
			end
		end

		payments
	end

  # Return the periodic payment due on a loan, based on the amortization
  # process.
	#
	# References:
	#  * http://en.wikipedia.org/wiki/Amortization_calculator
	def Finance.pmt(principal, rate, periods)
		principal * (rate + (rate / ((1 + rate) ** periods - 1)))
	end

	# Return the net present value of a sequence of cash flows given
	# the discount rate _rate_.
	#
	# References:
	#  * http://en.wikipedia.org/wiki/Net_present_value
	def Finance.npv(rate, cashflows)
		total = 0.0
		cashflows.each_with_index do |cashflow, index|
			total = total + cashflow / (1+rate) ** index
		end
		total
	end

	# Return the number of periods needed to pay off a loan with the
	# given payment.
	def Finance.nper(payment, rate, principal)
		-(Math.log(1-((principal/payment)*rate))) / Math.log(1+rate)
	end
end
