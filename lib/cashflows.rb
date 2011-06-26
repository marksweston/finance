module Cashflow
  # Return the {http://en.wikipedia.org/wiki/Internal_rate_of_return
  # internal rate of return} for a given sequence of cashflows.
  def irr(iterations=100)
    rate = 1.0
    investment = self[0]
    for i in 1..iterations+1
      rate = rate * (1 - self.npv(rate) / investment)
    end
    rate
  end

  # Return the {http://en.wikipedia.org/wiki/Net_present_value net present value} of a sequence of cash flows given
  # the discount rate _rate_.
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
