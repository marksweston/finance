#Copyright (c) 2011, William Kranec <wkranec@gmail.com>
#All rights reserved.
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

module Finance
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

	def Finance.pmt(principal, rate, periods)
		# See http://en.wikipedia.org/wiki/Amortization_calculator
		principal * (rate + (rate / ((1 + rate) ** periods - 1)))
	end

	def Finance.npv(rate, cashflows)
		total = 0.0
		cashflows.each_with_index do |cashflow, index|
			total = total + cashflow / (1+rate) ** index
		end
		total
	end

	def Finance.nper(payment, rate, principal)
		-(Math.log(1-((principal/payment)*rate))) / Math.log(1+rate)
	end
end
