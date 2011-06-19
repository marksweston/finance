require 'amortization'
require 'cashflow'
require 'rates'
require 'time'

# The *Finance* module adheres to the following conventions for
# financial calculations:
#
#  * Positive values represent cash inflows (money received); negative
#    values represent cash outflows (payments).
#  * *principal* represents the outstanding balance of a loan or annuity.
#  * *rate* represents the interest rate _per period_.
module Finance

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

	# Return the number of periods needed to pay off a loan with the
	# given payment.
	def Finance.nper(payment, rate, principal)
		-(Math.log(1-((principal/payment)*rate))) / Math.log(1+rate)
	end
end
