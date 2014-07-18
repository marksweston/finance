require_relative '../decimal'
require_relative '../rates'

require 'bigdecimal'
require 'bigdecimal/newton'
include Newton

module Finance
  module Calculator
    class Npv
      def initialize(values, rate)
        @values = values
        @rate = rate
      end

      # calculate the net present value of a sequence of cash flows
      # @return [DecNum] the net present value
      # @param [Numeric] rate the discount rate to be applied
      # @example
      #   Finance::Calculator::Npv.new([-100.0, 60, 60, 60], 0.1) #=> 49.211
      # @see http://en.wikipedia.org/wiki/Net_present_value
      # @api public
      def compute
        @values.collect! { |entry| Flt::DecNum.new(entry.to_s) }

        rate, total = Flt::DecNum.new(@rate.to_s), Flt::DecNum.new(0.to_s)
        @values.each_with_index do |cashflow, index|
          total += cashflow / (1 + rate) ** index
        end

        total
      end
    end
  end
end
