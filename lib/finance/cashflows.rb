module Finance
  module Cashflow
    # calculate the internal rate of return for a sequence of cash flows
    # @return [Numeric] the internal rate of return
    # @example
    #   [-4000,1200,1410,1875,1050].irr #=> 0.143
    # @see http://en.wikipedia.org/wiki/Internal_rate_of_return
    # @api public
    def irr(iterations=100)
      rate = 1.0
      investment = self[0]
      for i in 1..iterations+1
        rate = rate * (1 - self.npv(rate) / investment)
      end
      rate
    end

    # calculate the net present value of a sequence of cash flows
    # @return [Numeric] the net present value
    # @param [Numeric] rate the discount rate to be applied
    # @example
    #   [-100.0, 60, 60, 60].npv(0.1) #=> 49.211
    # @see http://en.wikipedia.org/wiki/Net_present_value
    # @api public
    def npv(rate)
      total = 0.0
      self.each_with_index do |cashflow, index|
        total = total + cashflow / (1+rate) ** index
      end
      total
    end

    # @return [Numeric] the sum
    # @api public
    def sum
      self.inject(:+)
    end

    def xirr
    end
  end
end

class Array
  include Finance::Cashflow
end
