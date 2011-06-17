module Cashflow
	# Return the internal rate of return for a given sequence of cashflows.
	#
	# References:
	#  * http://en.wikipedia.org/wiki/Internal_rate_of_return
	def irr(iterations=100)
		rate = 1.0
		investment = self[0]
		for i in 1..iterations+1
			rate = rate * (1 - self.npv(rate) / investment)
		end
		rate
	end

	# Return the net present value of a sequence of cash flows given
	# the discount rate _rate_.
	#
	# References:
	#  * http://en.wikipedia.org/wiki/Net_present_value
	def npv(rate)
		total = 0.0
		self.each_with_index do |cashflow, index|
			total = total + cashflow / (1+rate) ** index
		end
		total
	end

	def sum
		self.inject(:+)
	end

	def xirr
	end
end

class Array
	include Cashflow
end
